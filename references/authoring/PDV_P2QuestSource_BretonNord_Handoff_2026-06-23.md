# P2 Quest-Source FormList Handoff — Breton (Knight's Road + Vow) + Nord (KyneTalos)
**Date:** 2026-06-23
**Scope:** Populate three empty quest-source FormLists under gated-curation discipline.
**Out of scope (note only):** BretonGreenWaySources/Harvests (own env-shell handoff); BretonHiddenArtSources (already populated); NordOldWaysSources/NordHircineArkaySources (already populated).

---

## Mission

Three `PDV_FLST_P2_*Sources` FormLists are wired end-to-end but contain zero items.
No quest milestone awards these layers today. Populate each with 2–5 verified,
curated sources following the six-step chain and gated-fill discipline in
`references/authoring/PDV_P2QuestSourceFormList_AuditHandoff_2026-06-23.md`.

---

## FormLists in Scope

| FormList | Route call | Handler | Manifest sourceKinds | Gating note |
|---|---|---|---|---|
| `PDV_FLST_P2_BretonKnightsRoadSources` | `RouteBretonTraditionChoice(0, sourceId)` | `HandleBretonTraditionChoice` | `quest-stage`, `book` | **One-shot tradition-lock only.** See wiring note below. |
| `PDV_FLST_P2_BretonVowSources` | `RouteBretonKnightlyVow(sourceId)` | `HandleBretonKnightlyVow` | `quest-stage`, `book` | Repeating; anti-farmed via `ConsumeDailyRepeatMultiplier("PDV.Signal.BretonKnightlyVow")`. |
| `PDV_FLST_P2_NordKyneTalosSources` | `RouteNordKyneTalosContext(sourceId)` | `HandleNordKyneTalosContext` | `quest-stage`, `book`, `weather` | Weather sourceKind overlaps env-shell; quest-stage only in this handoff. See GAP below. |

---

## Wiring Chain Verification (steps 1–5)

All three FLSTs are confirmed wired for steps 1–3 (shell, alias property, registration):

- Shell + alias properties: PASS — `PDV_PlayerEvents.psc` line 18 (`PDV_FLST_P2_BretonKnightsRoadSources`), line 21 (`PDV_FLST_P2_BretonVowSources`), line 38 (`PDV_FLST_P2_NordKyneTalosSources`).
- Registration: PASS — `RegisterQuestStageList(PDV_FLST_P2_BretonKnightsRoadSources)` at line 669; `PDV_FLST_P2_BretonVowSources` at line 672; `PDV_FLST_P2_NordKyneTalosSources` at line 682.

Step 4 — route branches in `PDV_PlayerEvents.psc`:

- **BretonKnightsRoadSources:** `ShouldRouteP2Source(PDV_FLST_P2_BretonKnightsRoadSources, …, "breton_knights_road", sourceKind)` → `RouteBretonTraditionChoice(0, …)` at line 845–847. PRESENT.
- **BretonVowSources:** `ShouldRouteP2Source(PDV_FLST_P2_BretonVowSources, …, "breton_vow", sourceKind)` → `RouteBretonKnightlyVow(…)` at line 856–858. PRESENT.
- **NordKyneTalosSources (membership):** `ShouldRouteP2Source(PDV_FLST_P2_NordKyneTalosSources, …, "nord_kyne_talos", sourceKind)` → `RouteNordKyneTalosContext(…)` at line 910–912. PRESENT.
- **NordKyneTalosSources (exact-stage, MQ105 stage 160):** `ShouldRouteP2QuestStage(PDV_FLST_P2_NordKyneTalosSources, sourceQuest, 148154, 160, "nord_mq105_kyne_talos", newStage)` → `RouteNordKyneTalosContext("po3_queststage_nord_mq105_sky_road")` at line 998–1000. PRESENT. Route entry `nord-mq105-kyne-talos` in manifest: `reviewStatus: "approved-static-route-only"`.

Step 5 — EventBus → handler → piety increment:

- **RouteBretonTraditionChoice (PDV_EventBus.psc:1138–1151)** → `PDV_Manager.HandleBretonTraditionChoice` (`PDV__ManagerQuest.psc:12355`). **Wiring note:** This handler performs a one-shot tradition-lock (`ApplyBretonInitialChoice`). After `PDV.Breton.SetupComplete == 1`, subsequent sources with `traditionValue != locked-tradition` increment `CrossTraditionPressure` and return immediately — **no piety is awarded on repeat fires**. Sources placed in `BretonKnightsRoadSources` serve only to signal the Knight's Road tradition on first encounter (tradition-onboarding), not to award ongoing piety. That is by design. Codex must account for this: every source in this FLST fires the tradition lock once; subsequent hits are cross-tradition pressure only.
- **RouteBretonKnightlyVow (PDV_EventBus.psc:1154–1168)** → `PDV_Manager.HandleBretonKnightlyVow` (`PDV__ManagerQuest.psc:12432`). When `PDV.Breton.Tradition == 0` (Knight's Road): `ConsumeDailyRepeatMultiplier("PDV.Signal.BretonKnightlyVow")` guards repeats; then `AwardCuratedSignalScaled(PDV_Stendarr, PDV_Stendarr.SIGNAL_MERCY, None, multiplier)`. Piety increment confirmed.
- **RouteNordKyneTalosContext (PDV_EventBus.psc:1298–1312)** → `PDV_Manager.HandleNordKyneTalosContext` (`PDV__ManagerQuest.psc:12989`) → `RouteNordFamily(reason, …)` (`12948`). `RouteNordFamily` calls `GetNordRouteFamilyFromSource(reason)`, then `AwardNordRouteFamilySignal(routeFamily, multiplier)`.

### ⚠ GAP — NordKyneTalos sky_road piety not awarded

`GetNordRouteFamilyFromSource` maps tokens "sky_road", "storm_road", "road_grace" (without "nine") to `NORD_ROUTE_OLD_SKY_ROAD` (const = 1).
`AwardNordRouteFamilySignal` (`PDV__ManagerQuest.psc:12912`) has branches for `OLD_ORDEAL`, `OLD_HEARTH`, `OLD_ANCESTOR`, `OLD_TALOS`, `NINE_ROAD`, `NINE_MERCY`, `NINE_DEATH`, `NINE_WORK` — **but no branch for `NORD_ROUTE_OLD_SKY_ROAD`**.

Result: the membership route (`"quest-stage_nord_kyne_talos_sky_road"`) and the exact-stage MQ105 route (`"po3_queststage_nord_mq105_sky_road"`) both reach `AwardNordRouteFamilySignal` with family=1 and silently do nothing. The contextual favor fires, but no `AwardCuratedSignalScaled` call is made. **Kyne/Talos piety is not awarded for any NordKyneTalosSources source today, even if the list were populated.**

**CORRECTION (Claude review, 2026-06-23):** the one-liner originally proposed here
(`AwardCuratedSignalScaled(PDV_Kyne, PDV_Kyne.SIGNAL_OPEN_SKY, …)`) is **WRONG and will NOT
compile.** Verified against live source: `PDV_Deity_Kyne` defines **no** `SIGNAL_*` constants,
`PDV_DeityBase` defines none, and `AwardCuratedSignalScaled(PDV_Kyne, …)` is called **nowhere** —
Kyne has no curated-signal infrastructure, so `PDV_Kyne.SIGNAL_OPEN_SKY` does not exist
(`SIGNAL_OPEN_SKY = 1701` belongs to `PDV_Deity_Kynareth`). This is a **design decision**, not a
mechanical patch. Two valid resolutions for the owner to choose:

1. **Add curated-signal support to Kyne:** define a `SIGNAL_*` constant on `PDV_Deity_Kyne` (mirror
   how `PDV_Tsun.SIGNAL_TRIAL_ENDURED` / `PDV_Stuhn.SIGNAL_PROTECT_BOND` are declared on their deity
   scripts) + its curated delta, THEN add the `elseIf familyValue == NORD_ROUTE_OLD_SKY_ROAD` branch
   awarding it. This is real deity-architecture work, not a one-liner.
2. **Accept the existing channels:** Kyne's day-to-day likes-dislikes already scores event 313
   `rest-under-open-sky` + 345 `discover-location`, and the favor system maps sky-road to
   `FAVOR_FAMILY_OLD_WAYS_SKY_ROAD`. Under this reading the curated quest-source branch is
   intentionally absent; route NordKyneTalos sky-road quest sources to an already-supported
   deity/signal (e.g. `PDV_Talos.SIGNAL_SHRINE_DEFIANCE`, already in the switch) or omit the bump.

The GAP (favor fires, no curated piety) is real either way; the resolution is owner's-choice. **Do
NOT apply `PDV_Kyne.SIGNAL_OPEN_SKY`.**

Recompile `PDV__ManagerQuest.psc` and confirm `--check-route-entries` and e2e gate after the fix.

---

## Per-FormList Candidate Sources

### 1. PDV_FLST_P2_BretonKnightsRoadSources

**Contract:** Knight's Road tradition confirmation — vow, mercy, service, protection, or chivalric sources.
**Reject:** Generic helping, generic Daedric artifact ownership, generic spellcasting, or unrelated Breton quests.
**Reminder:** Every source fires only once (tradition-lock semantics). A single strong curated source is sufficient; more is acceptable for tradition-reinforcement breadth.

| Candidate | Quest/Form | Likely milestone stage | Rationale | Curation status |
|---|---|---|---|---|
| **Book of Love** — reuniting Calcelmo + Faleen and Fastred families; explicit mercy + service milestone. | `MS14` | ~100 (all couples reunited) | Mercy, protection, community duty — all Knight's Road virtues. Stendarr/Mara-adjacent. | VERIFY exact FormKey + stage via houseCARL |
| **Destroy the Dark Brotherhood** — choosing justice over joining; strongest chivalric threshold signal. | `DB08alt` or `DBDestroy` | Completion stage | Irreversible vow to the Nine Divines / moral order; hardest Knight's Road signal available. | VERIFY exact quest + stage; check `DBDestroyQuest` or related QUST FormKey |
| **The Taste of Death** (Namira's quest) — *refused* branch. If a route-by-refusal is possible, refusing Namira's feast is a curated mercy/vow signal. | `DA11` | Refused-feast stage if one exists | Confirms vow under temptation. Check whether a discrete "refused" stage exists in vanilla before adding. | VERIFY stage existence via houseCARL first; may not have a discrete stage |
| **Meridia's quest (The Break of Dawn)** — cleansing Kilkreath Temple. | `DA09` | 200 (beacon retrieved + Malkoran defeated) | Stendarr-adjacent: driving undead from a sacred site. Strongly chivalric; not Daedric-positive per Knight's Road (Meridia is enemy of undead, not a Daedric deal). | VERIFY exact FormKey + stage via houseCARL |
| **Companions quest: The Silver Hand** or **Purity of Revenge** — if used as a Knight's Road chivalric threshold (rescuing Companions, not the werewolf-gift stage). | `C04` or `C05` | Stage that rescues a Companion without accepting the beast-blood | Honor + defense of allies without corruption. Confirm the stage does not immediately precede beast-blood acquisition. | VERIFY exact stage; avoid stages that bleed into C03 beast-blood arc |

**Recommended starting fill:** 2–3 entries. `Book of Love` (MS14, high confidence) + `Destroy the Dark Brotherhood` (if FormKey confirmed) are the cleanest pair. Meridia (DA09) is a solid third.

---

### 2. PDV_FLST_P2_BretonVowSources

**Contract:** Curated vow, mercy, protection, service, or courtly-duty sources.
**Reject:** Generic favor quests, bounty loops, or faction rank alone.
**Note:** This is the piety-awarding track (repeating, daily-capped). Anti-farm is `ConsumeDailyRepeatMultiplier("PDV.Signal.BretonKnightlyVow")`.

| Candidate | Quest/Form | Likely milestone stage | Rationale | Curation status |
|---|---|---|---|---|
| **Book of Love (MS14)** — each major act of reuniting couples. | `MS14` | Stage per couple reunited (~50, 60, 70…) | Per-stage piety: each successful vow/mercy milestone is a discrete act, not a bounty loop. Multiple stages possible. | VERIFY exact FormKey + per-stage values via houseCARL |
| **The Cause (Dawnguard: helping Katria / Arkngthamz)** — alternatively any named Dawnguard rescue/protection quest. | `DLC1SV01` or `DGIntro` | Protection/rescue completion stage | Strong protection signal for a Knight. If DLC-gated, note that cleanly. | VERIFY exact FormKey + stage via houseCARL; flag DLC dependency |
| **Return to Grace (Pilgrim's path quests or shrine-restoration content)** — curated shrine repair or temple aid. | Varies | Completion | Service to the Nine Divines as vow-enactment. Prefer named-NPC-assisted temple restorations over anonymous gift. | VERIFY a curated vanilla candidate; may require checking UESP for Stendarr/Arkay/Mara quest side content |
| **Dungeon rescue — Sinding or similar single named-NPC rescue** — e.g. freeing Thorald from Northwatch Keep. | `MS08Northwatch` or similar | Stage: Thorald delivered to family | Explicit mercy/protection vow: rescue a named prisoner for a named family. No farmable repeat. | VERIFY exact quest FormKey + stage; this is `FreeformRorikstead` or `CWSiegeObj` territory — check UESP for the exact QUST |
| **Laid to Rest (Morthal vampire investigation)** — protecting Morthal from hidden undead threat; explicit community-defense completion. | `MS17` | 100 (Alva/Movarth defeated + community restored) | Service + protection of community. Stendarr-adjacent anti-undead closure with a mercy context (child). | VERIFY exact FormKey + stage via houseCARL |

**Recommended starting fill:** 3 entries. `Book of Love (MS14)` + `Laid to Rest (MS17)` + `Thorald rescue` (if QUST confirmed) cover mercy, community protection, and prisoner rescue without overlap.

---

### 3. PDV_FLST_P2_NordKyneTalosSources

**Contract:** Curated Kyne weather, storm, shout, Talos, or public pressure context.
**Reject:** Generic weather changes, generic shout use, or generic Civil War progress.
**Weather sourceKind:** Out of scope for this handoff (own env-shell work). Quest-stage + book only here.
**Fix required first:** Add `NORD_ROUTE_OLD_SKY_ROAD` branch to `AwardNordRouteFamilySignal` before filling.

Route entry `nord-mq105-kyne-talos` already exists in `routeEntries` (`reviewStatus: "approved-static-route-only"`). The FLST must contain the matching quest record for the stage gate to fire.

| Candidate | Quest/Form | formKey in manifest (if known) | Likely stage | Rationale | Curation status |
|---|---|---|---|---|---|
| **The Way of the Voice (MQ105)** — Greybeard / voice recognition milestone. | MQ105 | `0242BA:Skyrim.esm` (from routeEntry `expectedFormId: 148154`) | **160** (confirmed in routeEntry) | One-shot sky-road / voice recognition. Route entry approved-static-route-only; `approvedStages` must be `[160]`. `stageReadbackEvidence` must be filled via houseCARL QUST read. | formKey known; VERIFY stage log entry text via houseCARL QUST readback |
| **Talos Trouble (Karthwasten or Markarth Talos shrine content)** — player defends or protects a Talos shrine/worshipper. | Check `MS10` (Talos amulet/pilgrim content) or authored Thalmor-defiance quest | Varies | One-shot public Talos pressure from a curated named-NPC encounter with Thalmor; stronger than Civil War rank alone. | VERIFY if a discrete vanilla QUST exists; may be part of Civil War dialogue hooks or Thalmor Embassy content rather than a standalone quest |
| **The Whispering Door (Daedra's Best Friend)** — *if* refusing Mephala's door counts as a public Talos-framing of restraint. Likely too indirect; note only. | `DA08` | — | Not recommended as primary. Mention as rejected example matching rejectedUse. | N/A — likely rejected |
| **Sovngarde MQ — crossing Tsun's bridge** (MQ304, stage 200). Already in `NordOldWaysSources`; **do not duplicate** into KyneTalos. | — | — | Sky-road completion is already claimed by `nord-mq304-old-ways`. | EXCLUDE to avoid mutual exclusion conflict |
| **Diplomatic Immunity (MQ202 — infiltrate Thalmor Embassy)** — specific stage where the player encounters Thalmor Talos-ban evidence. | `MQ202` | Check `Skyrim.esm:xxxx` | Stage where Talos ban is personally confronted (dossier or interrogation room). One-shot high-cost Talos-pressure signal. | VERIFY exact FormKey + stage; avoid stages that are just "entered the Embassy" |

**Recommended starting fill:** 2 entries. MQ105 stage 160 is the anchoring source (route already verified); one curated Thalmor/Talos-confrontation source from MQ202 or similar would complete the initial set. Keep the fill small given the sky_road piety GAP must be fixed first.

---

## Gated Fill Protocol (clone from template)

Per `references/authoring/PDV_P2QuestSourceFormList_AuditHandoff_2026-06-23.md` §"The gated population mechanism":

1. For each candidate above: use houseCARL (`housecarl_read_record` on the QUST) to get the exact FormKey (`ModName.ext:localHex`) and confirm the milestone stage number plus its log-entry text.
2. Determine `approvedStages` (exact int list), `stageReadbackEvidence` (CSV path or inline note), `rejectedStageContext`, and `duplicateGuard` (`MarkP2SourceRoute stores quest form plus routeKey <id>`).
3. Add each to `sourceFillEntries` in `PDV_Phase20_P2ImmersiveReceivers.manifest.json` with `status: "approved-for-fill"`, `rationale`, and all required metadata fields.
4. Run `--fill-source-entries` (dry-run first if available) to write the FLST records to Devotion.esp.
5. Run the five check modes: `--check-formlists`, `--check-alias-properties`, `--check-source-fill`, `--check-route-entries`, `--check-exact-stage-gates`. All must PASS.
6. E2E gate: in-game, reach the milestone stage. Confirm Papyrus log: `Route<Family> complete` + handler trace + `AwardCuratedSignalScaled` line for the correct deity. One proof per FormList.

**For NordKyneTalosSources:** Fix `AwardNordRouteFamilySignal` (add `NORD_ROUTE_OLD_SKY_ROAD` branch → `PDV_Kyne.SIGNAL_OPEN_SKY`) and recompile `PDV__ManagerQuest.psc` before step 4. Confirm the compile is 0 errors. Then fill and run checks.

---

## Acceptance

A FormList is done when:

- [ ] `--check-formlists` PASS (shell exists)
- [ ] `--check-alias-properties` PASS (alias wired)
- [ ] `--check-source-fill` PASS (items in FLST)
- [ ] `--check-route-entries` PASS (route branch verified)
- [ ] `--check-exact-stage-gates` PASS (stages approved and metadata complete)
- [ ] E2E gate green (one Papyrus log trace per FormList confirming piety fires)
- [ ] For NordKyneTalosSources: `AwardNordRouteFamilySignal` patch compiled 0 errors; piety trace confirms `PDV_Kyne.SIGNAL_OPEN_SKY` fires

---

## Hand-Back

Deliver:
- Updated `PDV_Phase20_P2ImmersiveReceivers.manifest.json` with `sourceFillEntries` populated for all three FormLists.
- Patched `PDV__ManagerQuest.psc` (sky_road branch added) and fresh compiled `.pex`.
- Per-FormList status table: wired? populated? right quests? sky_road GAP fixed? in-game proven?
- Backup path of Devotion.esp after `--fill-source-entries` write.

---

## Files

| File | Purpose |
|---|---|
| `references/authoring/PDV_Phase20_P2ImmersiveReceivers.manifest.json` | Source of truth for acceptedUse, sourceKinds, sourceFillEntries |
| `references/authoring/PDV_P2QuestSourceFormList_AuditHandoff_2026-06-23.md` | Template: six-step chain, gated-fill rules |
| `live-source/Scripts/Source/PDV_PlayerEvents.psc` | Alias property declarations (lines 18–22, 37–38), route branches (845–858, 910–912), registration (669–682) |
| `live-source/Scripts/Source/PDV_EventBus.psc` | RouteBretonTraditionChoice (1138), RouteBretonKnightlyVow (1154), RouteNordKyneTalosContext (1298) |
| `live-source/Scripts/Source/PDV__ManagerQuest.psc` | HandleBretonTraditionChoice (12355), HandleBretonKnightlyVow (12432), HandleNordKyneTalosContext (12989), AwardNordRouteFamilySignal (12912, GAP at line ~12945), GetNordRouteFamilyFromSource (12841) |
| `race-sheets/PDV_RaceDesign_Breton.md` | Knight's Road signal table, integrity track, accepted hooks |
| `race-sheets/PDV_RaceDesign_Nord.md` | Kyne/Talos hook surface, Talos defiance rules, sky-road endurance |
| `tools/pdv-phase20-p2-receiver-author/` | Fill and check toolchain |
