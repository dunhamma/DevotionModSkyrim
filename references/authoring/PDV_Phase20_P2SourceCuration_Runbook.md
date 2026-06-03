# PDV Phase 20 P2 Source Curation Runbook

**Created:** 2026-06-03
**Status:** Curation handoff for Breton, Dunmer, Imperial, and Nord immersive receivers
**Owner:** Companion to `PDV_Phase20_P2ImmersiveReceivers.manifest.json`

## Purpose

The P2 receiver network is wired but intentionally inert until exact source
records are approved. This runbook records the source-selection boundary before
anything is added to the live `PDV_FLST_P2_*` FormLists.

Use this process:

1. Pick exact source records from local reference tables or CK/xEdit readback.
2. Confirm each source matches the route family and rejected-context rule.
3. Add only approved entries to `sourceFillEntries` in
   `PDV_Phase20_P2ImmersiveReceivers.manifest.json`.
4. Mark each live-fill entry `status: approved-for-fill`.
5. Run:

```powershell
dotnet run --project .\tools\pdv-phase20-p2-receiver-author\PdvPhase20P2ReceiverAuthor.csproj -- --fill-source-entries
dotnet run --project .\tools\pdv-phase20-p2-receiver-author\PdvPhase20P2ReceiverAuthor.csproj -- --check-source-fill
node .\tools\pdv_verify.mjs --strict-phase20-altmer --strict-phase20-race-costing --json
```

Do not use load-order FormIDs. Source entries use
`ModName.ext:localHex`, such as `Skyrim.esm:0ED04D`.

## Hard Stop Rules

- `vanilla-quest-candidates.csv` is scan-only. Do not approve a quest-stage
  source from that table until the specific quest stages/outcomes are read.
- The current PO3 quest-stage receiver sees quest form plus new stage. A quest
  FormList entry is safe only when any observed stage change is acceptable, or
  when the quest is proven terminal/source-marked for the intended route.
- Shrine blessing spells are not valid for the current spell-learned receiver.
  They may be future spell-effect or shrine-context sources, not current
  `OnSpellLearned` entries.
- Spell tomes can fire book-read and spell-learned paths. Pick one owner for
  each family before approval.
- Broad lore books can be useful one-shot flavor sources, but they must not
  become the primary route for a race if the intended end-state hook is civic,
  curse, quest, service, or public pressure.

## Initial Candidate Notes

These are candidate prompts, not approved source-fill entries.

| Race | Receiver property | Candidate source direction | Local evidence |
|---|---|---|---|
| Breton | `PDV_FLST_P2_BretonHiddenArtSources` | Reach, witchcraft, hagraven, Forsworn, and hidden-practice books can support a Hidden Art read route after semantic review. | `Book2CommonHagravens`, `Book2CommonMadmenoftheReach`, Forsworn notes, Anise's Letter in `vanilla-book-signal-candidates.csv` |
| Breton | `PDV_FLST_P2_BretonGreenWaySources` | Green Way should prefer nature-site, standing-stone, harvest, or Wyrd-like context. Current local book hits are weak and should not be approved alone. | Hook recipe supports harvest/weather/location context; no strong exact Breton Green Way source is approved yet |
| Breton | `PDV_FLST_P2_BretonKnightsRoadSources` / `PDV_FLST_P2_BretonVowSources` | Needs vow, mercy, service, or protection source readback. Quest stages are likely better than books, but they need exact stage/outcome proof first. | Quest crosswalk pattern supports curated quest-stage/faction signals only after record readback |
| Dunmer | `PDV_FLST_P2_DunmerAzuraSources` | Azura-specific books and Dragonborn Reclamation material are strong book-read candidates after semantic confirmation. | `Invocation of Azura`, `Azura and the Box`, `The Reclamations` |
| Dunmer | `PDV_FLST_P2_DunmerBoethiahSources` | Boethiah-specific books are strong one-shot book-read candidates; Daedric quest outcome still needs stage readback. | `Boethiah's Glory`, `Boethiah's Proving`; quest crosswalk has Boethiah sacrifice as stage-plus-kill candidate |
| Dunmer | `PDV_FLST_P2_DunmerMephalaSources` | Current extracted local hits are not sufficient for an approved Mephala book route. Prefer exact quest/book readback before approval. | Quest crosswalk has Mephala-adjacent Dark Brotherhood and Vaermina patterns, but not a clean Dunmer Reclamation source |
| Dunmer | `PDV_FLST_P2_DunmerDeviationSources` | Ash spells, Black Star/Azura outcome, vampire/curse, and rival-Prince pressure are plausible, but require owner selection and stage/effect proof. | Ash spell tomes in `vanilla-book-signal-candidates.csv`; Azura mutually exclusive quest rows in crosswalk |
| Imperial | `PDV_FLST_P2_ImperialCivicSources` | Imperial history/civic books can be light one-shot context; real civic service should use faction/quest/crime-chain proof after stage readback. | `Brief History of the Empire` volumes, `Life of Uriel Septim VII`, civil-war and destroy-Brotherhood rows in crosswalk |
| Imperial | `PDV_FLST_P2_ImperialPrivateTalosSources` / `PDV_FLST_P2_ImperialPublicTalosSources` | Talos pressure should not be generic shrine proximity. Public/private split likely needs quest/faction/dialogue context; book reads are secondary. | `The Talos Mistake`; Civil War and Concordat-pressure crosswalk rows |
| Imperial | `PDV_FLST_P2_ImperialPatronCivicSources` | Needs active-patron-aware civic service source. Do not approve generic favor quests. | Crosswalk supports curated civic/justice/faction milestones, not broad service loops |
| Nord | `PDV_FLST_P2_NordOldWaysSources` | Nord identity and afterlife books are viable one-shot context, but should be balanced against normal-play quest/shout/weather routes. | `Nords Arise!`, `A Dream of Sovngarde`, `Nords of Skyrim`, `Sovngarde: A Reexamination` |
| Nord | `PDV_FLST_P2_NordKyneTalosSources` | Kyne/Talos should prefer shout/weather/public-pressure hooks. Books can be context only. | Kyne's Peace voice records and Talos/Kyne blessing records exist, but current receiver does not score shrine effects |
| Nord | `PDV_FLST_P2_NordHircineArkaySources` | Werewolf, Hircine, Arkay, and death-duty records are plausible edge hooks, but source ownership must avoid generic curse/undead farming. | `The Totems of Hircine`, werewolf abilities, Arkay blessing spell, Companions cure rows in crosswalk |

## Approval Template

Add approved entries in the manifest only after the curation decision is closed:

```json
{
  "property": "PDV_FLST_P2_DunmerAzuraSources",
  "sources": [
    {
      "formKey": "Skyrim.esm:01B245",
      "editorId": "Book4RareInvocationofAzura",
      "sourceKind": "book",
      "status": "approved-for-fill",
      "rationale": "One-shot Azura-specific devotional text; not a generic Daedric source."
    }
  ]
}
```

After fill, empirical proof still requires accepted trigger, wrong-origin
silence, generic-source silence, repeat behavior, Survey clarity, stack
snapshot, and manual feel evidence.
