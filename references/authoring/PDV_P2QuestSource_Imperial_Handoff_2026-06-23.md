# P2 Quest-Source FormList Handoff — Imperial (2026-06-23)

**Mission:** Populate the 8 empty `PDV_FLST_P2_Imperial*` quest-source FormLists under the
project's gated curation discipline. Imperial is the worst-off race — no quest sources trigger
civic or Talos piety today. All 8 lists are wired (steps 1–4 complete) but one structural gap
(step 3, registration) blocks 5 of the 8 family-specific lists from ever firing. Fix that gap
first; then curate and fill sources.

---

## WIRING GAP — MUST FIX BEFORE FILLING

**GAP (Step 3 — Registration):** Five family-specific Imperial FormLists are **not registered**
with `RegisterQuestStageList` in `PDV_PlayerEvents.psc`. Without registration, PO3's
`OnStoryQuestStarted` never fires for their members, so the route branches at lines 882–895
are dead regardless of what goes in the FormLists.

**Missing from the `RegisterQuestStageList` block (lines 677–680):**
- `PDV_FLST_P2_ImperialPublicServiceSources`
- `PDV_FLST_P2_ImperialMercySources`
- `PDV_FLST_P2_ImperialLawfulOrderSources`
- `PDV_FLST_P2_ImperialHonestWorkSources`
- `PDV_FLST_P2_ImperialDeathDutySources`

**Fix:** Add 5 `RegisterQuestStageList(...)` calls immediately after line 677 in
`live-source/Scripts/Source/PDV_PlayerEvents.psc`, then recompile. Reconfirm with
`--check-route-entries` after fill.

The 3 already-registered lists (`ImperialCivicSources`, `ImperialPrivateTalosSources`,
`ImperialPublicTalosSources`, `ImperialPatronCivicSources`) are unaffected — their
registration is present.

---

## FormLists In Scope

| FormList | Route fn (EventBus.psc) | Handler fn (ManagerQuest.psc) | Increment site | acceptedUse (short) | rejectedUse (short) | Steps 1–5 |
|---|---|---|---|---|---|---|
| `ImperialCivicSources` (legacy) | `RouteImperialCivicService` (L1234) | `HandleImperialCivicService` (L12766) | `AwardImperialCivicFamilySignal` → `SIGNAL_CIVIC_SERVICE` on Akatosh; `ConsumeDailyRepeatMultiplier` key `PDV.Signal.ImperialCivicService.public_service` (L12778) | Legacy civic sources; new fills prefer family-specific lists | Generic faction, generic commerce, ordinary city travel | ✅ 1–5 COMPLETE |
| `ImperialPublicServiceSources` | `RouteImperialCivicService` (L1234); token `_imperial_public_service` | `HandleImperialCivicService` (L12766) | `AwardImperialCivicFamilySignal` → `SIGNAL_CIVIC_SERVICE` on Akatosh; anti-farm per family label (L12778) | Legion/hold public service, infrastructure, civic-duty milestones | Faction membership, rank, generic city travel | ⚠️ STEP 3 GAP: missing `RegisterQuestStageList` |
| `ImperialMercySources` | `RouteImperialCivicService` (L1234); token `_imperial_mercy` | `HandleImperialCivicService` (L12766) | `AwardImperialCivicFamilySignal` → `SIGNAL_MERCY` on Mara; anti-farm key `...mercy` (L12778) | Mercy, protection, family, relief milestones | Generic helping, generic healing, charity loops | ⚠️ STEP 3 GAP: missing `RegisterQuestStageList` |
| `ImperialLawfulOrderSources` | `RouteImperialCivicService` (L1234); token `_imperial_lawful_order` | `HandleImperialCivicService` (L12766) | `AwardImperialCivicFamilySignal` → `SIGNAL_LAWFUL_ORDER` on Stendarr; anti-farm key `...lawful_order` (L12778) | Guard, justice, Stendarr-adjacent, public-protection milestones | Bounty payment alone, generic crime, cruelty as order | ⚠️ STEP 3 GAP: missing `RegisterQuestStageList` |
| `ImperialHonestWorkSources` | `RouteImperialCivicService` (L1234); token `_imperial_honest_work` | `HandleImperialCivicService` (L12766) | `AwardImperialCivicFamilySignal` → `SIGNAL_HONEST_WORK` on Zenithar; anti-farm key `...honest_work` (L12778) | Craft, commerce, infrastructure, fair-dealing milestones | Raw barter, generic vendor, crafting loops | ⚠️ STEP 3 GAP: missing `RegisterQuestStageList` |
| `ImperialDeathDutySources` | `RouteImperialCivicService` (L1234); token `_imperial_death_duty` | `HandleImperialCivicService` (L12766) | `AwardImperialCivicFamilySignal` → `SIGNAL_DEATH_DUTY` on Arkay; anti-farm key `...death_duty` (L12778) | Arkay/funeral, Hall of the Dead, anti-necromancy civic milestones | Generic undead killing, tomb travel, Arkay shrine alone | ⚠️ STEP 3 GAP: missing `RegisterQuestStageList` |
| `ImperialPrivateTalosSources` | `RouteImperialTalosPressure(true, ...)` (L1250) | `HandleImperialTalosPressure` (L12791); anti-farm key `PDV.Signal.ImperialPrivateTalosPressure` → `SIGNAL_SHRINE_DEFIANCE` on Talos (L12810) | `ConsumeDailyRepeatMultiplier` (L12802) | Private Talos pressure, secrecy-mattering sources | Generic shrine use, generic Talos proximity | ✅ 1–5 COMPLETE |
| `ImperialPatronCivicSources` | `RouteImperialPatronCivicFavor` (L1266) | `HandleImperialPatronCivicFavor` (L12824); anti-farm key `PDV.Signal.ImperialPatronCivicFavor` → `AwardImperialPatronCivicSignal` on active patron (L12837) | `ConsumeDailyRepeatMultiplier` (L12830) | Active-patron-lane civic milestones | Generic favor quests, public-service loops | ✅ 1–5 COMPLETE |

> **Family-token routing recap:** `HandleImperialCivicService` calls `GetImperialCivicFamilyFromSource`
> (L12686), which reads the `sourceId` string for substrings: `public_service` → Akatosh,
> `mercy` → Mara, `lawful_order` or `law` → Stendarr, `honest_work` or `work` → Zenithar,
> `death_duty` or `arkay` → Arkay. The `ShouldRouteP2Source` call in PlayerEvents (L879–895)
> bakes the family token directly into the `sourceKind + "_imperial_<family>"` string, so the
> token arrives embedded and the router resolves correctly — IF the FormList is registered.
> Without registration, the PO3 event never fires and the entire chain is silent.

---

## Candidate Sources per FormList

All candidates require: houseCARL QUST stage-read to confirm exact milestone stage + log entry text,
then manifest `routeEntries` entry + `sourceFillEntries` entry with full gated fields before fill.

### 1. `PDV_FLST_P2_ImperialCivicSources` (legacy — prefer family-specific below; still empty)

acceptedUse: legacy civic sources with `public_service` family token baked. Route already appends
`_imperial_civic_public_service` (L880), so any source here resolves to Akatosh `SIGNAL_CIVIC_SERVICE`.

| Candidate | Quest / context | Likely milestone stage | Notes |
|---|---|---|---|
| Imperial Legion muster / allegiance oath | `CW01A` or `CWSiegeObj` | VERIFY via houseCARL stage-read | One-shot Legion enlistment as civic-duty milestone; rejects generic Legion combat |
| Whiterun aid (thane) | `Favor257` (Whiterun thane quest) | VERIFY stage = completion marker | Concrete hold-aid milestone; rejects generic attendance |
| Dragon attack on Helgen resolution | `MQ102` | VERIFY stage for post-Helgen report | One-shot public-safety civic milestone |
| Riften city restoration aid | Relevant Riften aid quest | VERIFY | Lawful civic milestone for hold-service; must be concrete act, not city travel |

### 2. `PDV_FLST_P2_ImperialPublicServiceSources` (family: `public_service` → Akatosh)

acceptedUse: Legion public-service quest stages, thane/hold-aid beats, dragon-order/public-safety milestones.
rejectedUse: Faction membership, rank, generic city travel.

| Candidate | Quest / context | Likely milestone stage | Notes |
|---|---|---|---|
| Imperial Legion quest — "The Jagged Crown" | `CW02A` or `CWSoldierStage` | VERIFY terminal stage | One-shot major Legion public-service milestone; rejects generic allegiance |
| Jarl's aid — Whiterun thane quest | `Favor257` | VERIFY completion stage | Concrete hold-aid; one per hold; strong public-service shape |
| Dragon Bridge community defense | `MQ102` post-Helgen public report | VERIFY stage | Public-safety milestone, one-shot, fits civic-duty |
| Helgen survivor aid / Bleak Falls Barrow | `MQ103` completion | VERIFY stage | Concrete commissioned act for public safety; not generic adventuring |
| Legion general quest chain completion | `CWMission*` terminal stage | VERIFY | Meaningful capstone; must be post-battle resolution, not patrol loops |

### 3. `PDV_FLST_P2_ImperialMercySources` (family: `mercy` → Mara)

acceptedUse: Mercy, protection, family, relief milestones. Must represent genuine restraint or aid, not generic help.
rejectedUse: Generic helping, generic healing, charity loops.

| Candidate | Quest / context | Likely milestone stage | Notes |
|---|---|---|---|
| "In My Time of Need" (MS08) — Saadia aid branch | `MS08` stage ~100 or 200 (Forebear mercy) | VERIFY; check mutual exclusion with RedguardForebear (different race, no conflict) | Concrete mercy act; rejects siding with Alik'r as generic combat |
| "A Night to Remember" (DA14) — clean-up mercy | `DA14` completion stage | VERIFY | Comedy-mercy arc: restore harm done; one-shot cleanup milestone |
| Temple of Mara marriage quest completion | `RelationshipMarriage*` final stage | VERIFY | Community/family restoration milestone; Mara-coded; once per save |
| "Blood on the Ice" (MS11) — save Susanna / clear Wuunferth | `MS11` final acquittal stage | VERIFY | Justice-and-mercy intersection; one-shot |
| "The Whispering Door" (DA08) — resist corruption | BLOCKED — check if Madness outcome conflicts | VERIFY | Only if mercy/protection framing is the dominant branch; likely rejected |

### 4. `PDV_FLST_P2_ImperialLawfulOrderSources` (family: `lawful_order` → Stendarr)

acceptedUse: Lawful order, guard justice, Stendarr-adjacent, public-protection milestones.
rejectedUse: Bounty payment alone, generic crime, cruelty framed as order.

| Candidate | Quest / context | Likely milestone stage | Notes |
|---|---|---|---|
| "Blood on the Ice" (MS11) — full resolution | `MS11` final stage (expose real killer) | VERIFY | Quintessential lawful-order milestone; Windhelm justice arc |
| Stendarr's Beacon / Vigilants quest | Any Vigilant quest terminal | VERIFY | Stendarr-adjacent lawful-protection; check if Vigilant content has clean stages |
| "In My Time of Need" (MS08) — Alik'r justice branch | `MS08` stage 200 (hand over Saadia) | VERIFY; mutually exclusive with mercy branch | Lawful-order reading of the justice faction; reject if framed as cruelty |
| "Ill Met By Moonlight" (DA05) stage 100 — execute Sinding | Already used (Bosmer/Nord); reuse is cross-race fine | VERIFY cross-race duplicate-guard; same quest, different race, different routeKey | One-shot lawful-order execution of a fugitive; check if family token resolves correctly |
| Clearing a necromancer lair for a hold guard quest | Relevant radiant bounty (curated named instance) | VERIFY — must be named, not radiant loop | Stendarr/Arkay intersection; cite specific named quest only |

### 5. `PDV_FLST_P2_ImperialHonestWorkSources` (family: `honest_work` → Zenithar)

acceptedUse: Craft, commerce, infrastructure, fair-dealing milestones.
rejectedUse: Raw barter, generic vendor use, crafting loops, ordinary wealth accumulation.

| Candidate | Quest / context | Likely milestone stage | Notes |
|---|---|---|---|
| Thieves Guild — "Speaking With Silence" or "Hard Answers" completion | `TG06`/`TG07` stage VERIFY | NOT for Zenithar; reject — guild is the opposite of honest commerce |
| "The Forsworn Conspiracy" (MS02) — expose plot | `MS02` exoneration stage | VERIFY | Fair-dealing and justice milestone; concrete civic-commerce context |
| Bards' College — "Tending the Flames" completion | `BQ01` final stage | VERIFY | Cultural work completion; honest-work milestone via institutional craft |
| Temple of Julianos book-reading milestone | Not a quest stage; use book-read FormList instead | N/A | Route this to book-read FLST, not this list |
| "The Raid" (DialogueCidhnaMinePrisoner) | VERIFY | VERIFY | Labor/work-contract context; needs clean completion milestone not available in radiant form |
| Blacksmith commission quest (any named merchant) | Curated named merchant chain | VERIFY — check if named stage exists | Quality-work commissioned; must be a named quest milestone, not crafting loop |

### 6. `PDV_FLST_P2_ImperialDeathDutySources` (family: `death_duty` → Arkay)

acceptedUse: Arkay/funeral, Hall of the Dead, anti-necromancy civic milestones.
rejectedUse: Generic undead killing, tomb travel, Arkay shrine proximity alone.

| Candidate | Quest / context | Likely milestone stage | Notes |
|---|---|---|---|
| "The Book of Love" (MS14) / Hall of the Dead — Whiterun Arkay | `MS14` stage VERIFY | Strong Arkay death-duty milestone; Temple of Arkay named quest | One of the cleanest Imperial death-duty surfaces per race-sheet |
| "The Book of Love" — Riften Hall of the Dead (Arkay priest Runil) | `MS14` Riften stage | VERIFY separate stage or same quest | Named burial/death-rite milestone; Runil is a priest of Arkay |
| "Laid to Rest" (MS13) | `MS13` final stage | VERIFY | Burial-restoration / anti-necromancy milestone; one-shot village restoration |
| "Restoring Order" (dunpinewatchquest) | VERIFY if named quest stage exists | VERIFY | Anti-necromancer operation; hold-quest shape; must be named, not radiant |
| Falkreath Hall of the Dead — priest quest | VERIFY named quest ID | VERIFY | Named Arkay priest interaction; per-hold one-shot |

### 7. `PDV_FLST_P2_ImperialPrivateTalosSources` (family: `isPrivate=true` → `SIGNAL_SHRINE_DEFIANCE` on Talos)

acceptedUse: Private Talos pressure or repair where secrecy matters.
rejectedUse: Generic shrine use, generic Talos proximity.

| Candidate | Quest / context | Likely milestone stage | Notes |
|---|---|---|---|
| "Season Unending" / "Diplomatic Immunity" (MQ201) — refuse to denounce Talos worshipper | MQ201 stage VERIFY | Private conscience act; high-risk, one-shot | Must isolate the specific dialogue stage where refusal is recorded |
| Markarth hidden Talos shrine activation | Activator / stage VERIFY — may not have a QUST stage | If no stage, use activator trigger not quest stage | One-shot private defiance; ConcordatStanding -15 already fires, this adds private Talos piety |
| "The Forsworn Conspiracy" (MS02) — help Talos worshipper in Cidhna Mine | `MS02` specific stage VERIFY | Private act of conscience under Thalmor pressure | Must not conflict with LawfulOrder routing of same quest |
| "Diplomatic Immunity" (MQ201) — slip past Thalmor patrols without denouncing | Stage VERIFY | Hidden defiance context; must be the non-reporting branch only | |

### 8. `PDV_FLST_P2_ImperialPatronCivicSources` (patron-specific → `AwardImperialPatronCivicSignal` on `_activeDeity`)

acceptedUse: Patron-lane civic milestones (fires against whichever of the Nine Divines is the active patron).
rejectedUse: Generic favor quests, public-service loops (already covered by family-specific lists).

| Candidate | Quest / context | Likely milestone stage | Notes |
|---|---|---|---|
| Temple of Mara restoration / community-reunion milestones | Mara-patron: `MS14` Book of Love | VERIFY | Only fires if Mara is active patron; strong Mara patron-civic shape |
| Bards' College "Tending the Flames" | Julianos/Dibella patron | VERIFY completion stage | Cultural-civic work; patron-coded but must not double-fire with HonestWork |
| College of Winterhold final thesis / MG08 | Julianos patron | `MG08` stage 200 VERIFY | Magnus/Julianos scholarly civic milestone; unique patron-civic shape |
| "The Blessings of Nature" (MS07) | Kynareth patron | `MS07` terminal stage VERIFY | Patron-civic milestone for Kynareth-focused Imperial; tree-restoration = civic act |
| Vigilants aid quest terminal | Stendarr patron | VERIFY named quest stage | Stendarr patron-civic capstone; reject if already in LawfulOrder list |

---

## Gated-Fill Requirement Block

Per `PDV_Phase20_P2ImmersiveReceivers.manifest.json` `entryRule` and tool validation,
**every** quest-stage source entry in `sourceFillEntries` MUST have ALL of:

```json
{
  "property": "PDV_FLST_P2_Imperial<Family>Sources",
  "sources": [{
    "formKey": "<ModName.ext:localHex>",
    "editorId": "<EditorID>",
    "sourceKind": "quest-stage",
    "status": "approved-for-fill",
    "rationale": "...",
    "approvedStages": [<exact integer>],
    "stageReadbackEvidence": "references/vanilla-gameplay/extracted/vanilla-quest-stage-readback.csv",
    "rejectedStageContext": "...",
    "duplicateGuard": "MarkP2SourceRoute stores quest form plus routeKey <imperial_<id>>."
  }]
}
```

AND a parallel `routeEntries` record in the manifest with:

```json
{
  "id": "imperial-<quest>-<family>",
  "race": "Imperial",
  "property": "PDV_FLST_P2_Imperial<Family>Sources",
  "sourceKind": "quest-stage",
  "formKey": "<key>:Skyrim.esm",
  "expectedFormId": <int>,
  "approvedStage": <int>,
  "routeKey": "imperial_<quest>_<family>",
  "dispatch": "PDV_EventBusService.Route<appropriate>(\"po3_queststage_imperial_<id>\")",
  "acceptedContext": "...",
  "rejectedContext": "...",
  "duplicateGuard": "MarkP2SourceRoute stores quest form plus routeKey.",
  "stageReadbackEvidence": "references/vanilla-gameplay/extracted/vanilla-quest-stage-readback.csv",
  "implementationStatus": "route-verified-pending-source-fill",
  "reviewStatus": "approved-static-route-only"
}
```

The fill tool (`--fill-source-entries`) refuses entries missing any required field, rejects
`sourceKind` values not on the target receiver property, and rejects duplicate
property/form/sourceKind entries. Do not bypass.

**Book-read sources** (if any Imperial-relevant civic books exist) follow a simpler path:
no `approvedStages`/`stageReadbackEvidence`/`rejectedStageContext`/`duplicateGuard` required —
just `formKey`, `editorId`, `sourceKind: "book"`, `status: "approved-for-fill"`, `rationale`.

---

## Acceptance Criteria

A FormList is "done" when:

1. `--check-formlists` — shell record present (already PASS per aliasPropertyReadback)
2. `--check-alias-properties` — alias property wired (already PASS)
3. `--check-source-fill` — FormList contains the approved curated entries
4. `--check-route-entries` — every filled quest-stage source has a matching manifest route entry
5. `--check-exact-stage-gates` — every quest-stage entry has `approvedStages` + `questStageGate.receiverStatus == "exact-stage-supported"`

All five must be GREEN before declaring a FormList done.

Post-fill in-game gate: complete one milestone quest, confirm Papyrus log shows
`RouteImperialCivicService complete` (or `RouteImperialTalosPressure`/`RouteImperialPatronCivicFavor`)
AND the handler's family-label trace (`family public_service` / `mercy` / etc.), firing exactly once
(repeat: multiplier → 0.0 on second attempt).

---

## Hand-Back Deliverables

1. **Fix PDV_PlayerEvents.psc** — add 5 missing `RegisterQuestStageList` calls, recompile, confirm
   `--check-route-entries` green. This is the prerequisite for everything else.

2. **Manifest updates** — for each approved source:
   - Add `routeEntries` entry (one per quest/stage)
   - Add `sourceFillEntries` entry with all gated fields

3. **One backed-up ESP write** — `--fill-source-entries` write for each FormList after houseCARL
   stage-read confirms exact milestone stage. Backup path convention:
   `D:\Wabbajack\modlists\Anvil\mods\Devotion\Backups\phase20-p2-receivers\Devotion.esp.<timestamp>.bak`

4. **Per-FormList status table:**

| FormList | Registration fixed? | Sources filled (#) | --check-* GREEN? | In-game proven? |
|---|---|---|---|---|
| ImperialCivicSources | n/a (was registered) | 0 → ? | pending | pending |
| ImperialPublicServiceSources | ❌ → fix first | 0 → ? | pending | pending |
| ImperialMercySources | ❌ → fix first | 0 → ? | pending | pending |
| ImperialLawfulOrderSources | ❌ → fix first | 0 → ? | pending | pending |
| ImperialHonestWorkSources | ❌ → fix first | 0 → ? | pending | pending |
| ImperialDeathDutySources | ❌ → fix first | 0 → ? | pending | pending |
| ImperialPrivateTalosSources | n/a (was registered) | 0 → ? | pending | pending |
| ImperialPatronCivicSources | n/a (was registered) | 0 → ? | pending | pending |

---

## Files

| File | Role |
|---|---|
| `live-source/Scripts/Source/PDV_PlayerEvents.psc` | Fix: add 5 `RegisterQuestStageList` calls (after L677); route branches already at L879–905 |
| `live-source/Scripts/Source/PDV_EventBus.psc` | Routes: `RouteImperialCivicService` L1234, `RouteImperialTalosPressure` L1250, `RouteImperialPatronCivicFavor` L1266 |
| `live-source/Scripts/Source/PDV__ManagerQuest.psc` | Handlers: `HandleImperialCivicService` L12766, `HandleImperialTalosPressure` L12791, `HandleImperialPatronCivicFavor` L12824; family dispatch `AwardImperialCivicFamilySignal` L12718 |
| `references/authoring/PDV_Phase20_P2ImmersiveReceivers.manifest.json` | Add `routeEntries` + `sourceFillEntries` for each approved Imperial source |
| `references/authoring/PDV_Phase20_P2SourceCuration_Runbook.md` | Curation runbook — read before authoring manifest entries |
| `references/authoring/PDV_RaceDesign_Imperial.md` | Race sheet — lore, hook candidates, ConcordatStanding rules |
| `tools/pdv-phase20-p2-receiver-author/Program.cs` | Author tool — all `--check-*` modes + `--fill-source-entries` |
| `references/vanilla-gameplay/extracted/vanilla-quest-stage-readback.csv` | Stage evidence source; cite in `stageReadbackEvidence` |
