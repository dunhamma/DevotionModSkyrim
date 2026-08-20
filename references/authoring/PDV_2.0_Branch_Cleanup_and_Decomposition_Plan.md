# PDV 2.0 Branch Cleanup and Decomposition Plan

> **Status (2026-08-18):** LIVING. Reconciled from the stale, undated `PDV_1.1_Branch_Cleanup_and_Decomposition_Plan.md` draft, whose worldview topped out at the 1.0.x line and whose branch bootstrap (cut from `release/1.0.3`, cherry-pick 1.0.4) would have discarded the entire shipped 1.5.x line plus the 69 V3 commits. Renumbered to **2.0.0** and re-based on the reality below.
>
> **Ratified decisions this reconciliation records:**
> - **Next public version = `2.0.0`** — a major, not-save-safe overhaul after the shipped `1.5.x` line. "V3" is an internal architecture-generation nickname (from `FRAMEWORK_SCHEMA_VERSION = 3`, a no-op save-schema stamp) carried by the branch `feature/v3-big-update` and mod folder `Devotion-V3Dev`; it is **not** a public version. Nothing ships as "3.0".
> - **Source stamp:** `PDV_BUILD_VERSION` (`PDV__ManagerQuest.psc:607`, the machine-gated single source of truth) set to `"2.0.0-dev"` and compiled into `Devotion-V3Dev`; drop the `-dev` suffix when the release is cut.
> - **Branch base:** continue on `feature/v3-big-update` (already contains `v1.5.0d` + 69 commits + all merged `codex/v3-*` fixes). No re-cut.
>
> **Implementation checkpoint (2026-08-20):** ORIGIN, RECOGNITION, and PRISMA are extracted and merged checkpoint-by-checkpoint into `feature/v3-big-update`. PRISMA now resides in `PDV_PrismaPresenter` (114 functions; 48 public / 66 private) with per-race content supplied by the accepted ORIGIN presentation hook. Compile, extraction-specific, direct houseCARL VMAD/readback, and SEQ proof are green. Fresh-game/player-surface proof, legacy verifier/gate residence refresh, stale manager VMAD-fill cleanup, profiler comparison, and package acceptance remain later proof buckets; they are not implied by the static checkpoint.
>
> **Open reconciliation loose ends (not blockers for this plan):**
> - `hotfix/1.5.0e-daedric-consent-kid` (`409609b7`) is **not** merged into `feature/v3-big-update` — its Daedric-consent fixes are not yet in the V3 line. Deferred by owner decision; merge before the 2.0 release closeout.
> - `dist/PDV_QuestModPatches_FOMOD/fomod/info.xml` still carries a tracked `<Version>3.0.0-alpha</Version>` placeholder for the separately-versioned Quest-Reaction-Compatibility sub-package (the shipper regenerates it from `--version`). Confirm the compat-hub's intended version independently before editing.
> - The numbering ratification above is recorded here; its permanent home is the `AGENTS.md` Decisions Log (add on owner approval — `AGENTS.md` is not edited without an explicit ask).

## Outcome

Prepare a new-game-only 2.0 release that removes proven dead topology, replaces shallow VMAD duplication with authoritative contracts, decomposes the manager into deep domain modules, and ships through exact compile, houseCARL, runtime, and package gates.

The work is intentionally order-agnostic after branch bootstrap. Save compatibility is not a constraint. Gameplay behavior, route ownership, native bridge functions, and Prisma payload contracts remain constraints.

## 1. Branch and authority bootstrap

1. Continue on `feature/v3-big-update` (tip `bad88175` at reconciliation time). It already contains the full shipped `1.5.x` line (`v1.5.0`, `v1.5.0d` are ancestors) plus 69 V3 commits and every merged `codex/v3-*` fix. **Do not** re-cut from `release/1.0.3`/1.0.4 — those baselines are ancestors already baked in, and re-cutting would discard 1.0.4 → 1.5.0d and the V3 work. Use isolated worktrees off this branch for parallel lanes (Section 4).
2. Run the complete unchanged baseline (compile / verifier / houseCARL / package gates) before any retirement, so every later delta is measured against a green start.
3. Add an ADR superseding ADR-0004 for 2.0:
   - 2.0 requires a new game;
   - legacy FormIDs, scripts, properties, VMAD bindings, and StorageUtil migration code may be physically removed;
   - 1.5.x remains the save-compatible line.
4. Create `PDV_2_0Retirement.manifest.json` as the only retirement authority. Every row records:
   - FormKey/EditorID or script/property/function name;
   - classification: retire, replace, retain, or implement;
   - replacement owner and architecture citation;
   - incoming record, VMAD, source/PEX, manifest, verifier, and runtime-lookup evidence;
   - expected final state and required proof.

All agents and tools consume this ledger rather than maintaining separate candidate lists.

## 2. Retirement and replacement decisions

| Candidate | 2.0 decision |
|---|---|
| Generic `PDV_SacredPlace` scaffold | Retire its declaration-only PSC/PEX, three inert quests, obsolete FormLists, bindings, manifests, and verifier rules. Preserve the live race mechanics. |
| Argonian Bed-of-Choice | Retain. It is live through sleep routing, manager state, and `PDV_Substrate_ArgonianHist`; it feeds People/practice, Rooted Rest, and the permanent adaptation rite. Extract intact into the Argonian runtime module. |
| Orc Hearth-Held/community | Retain. The cell-keyed hearth, community route, Trial of Iron, notices, and reward behavior are live. Extract intact into the Orc runtime module. |
| Khajiit road homes | Retain the live outdoor-rest cadence; remove only obsolete SacredPlace topology. |
| Four legacy state-track quests | Retire `NordWorship`, `BretonTradition`, `DunmerPath`, and legacy `AltmerCrisis` records/globals/list entries. Protect the active replacement state and substrate records. |
| `DeityDomain` VMAD property | Replace with structured deity/Prince contract metadata, then remove all declarations, bindings, repair branches, and stale verifier expectations. |
| Three manager Altmer spine spell properties | Replace manager stripping with `PDV_AltmerAncestorSubstrate.ClearSubstrateBoons()`, then remove duplicate properties and bindings. |
| Eleven unbound Daedric messages | Remove six Hircine/Molag standalone stigma properties because curse-state presentation owns them. Remove five intentionally silent native-race response properties: Dunmer–Mephala, Dunmer–Boethiah, Dunmer–Azura, Khajiit–Azura, and Orc–Malacath. |
| Breton Hidden Art Prince responses | Retain as explicit authored cultural exceptions. Healthy Hidden Art suppresses duplicate global price/stigma, not its racial Prince responses. |
| 53 declaration-only manager functions | Retire by domain batch after machine proof excludes events, overrides, native bindings, MCM/debug callers, verifier contracts, and name-based runtime lookup. |
| HealRate/Argonian disease MGEFs | Delete only exact FormIDs proven to have zero incoming record, source/PEX, manifest, and runtime lookup references. Never delete by substring; protect active penalty and reward effects. |
| Redundant route wrappers | Remove only zero-caller compatibility wrappers after callers are rerouted to their owning receiver. |
| Reserved curated signals | Implement `CARAVAN_AID`, `LEGEND_MADE`, `WEB_WOVEN`, and `HONORABLE_DUEL` through their existing route owners. Do not confuse them with dead wrappers. Retire `OPEN_ROAD` if its final callgraph remains empty/superseded. |
| Whole scripts | No current PSC/PEX pair is an orphan. A script becomes removable only when the retirement ledger proves attachment, source, runtime lookup, and migration obligations are all absent. |

Correct the architecture and Beta Contract at the same time as each retirement. In particular, replace claims that Argonian Bed-of-Choice runs “via `PDV_SacredPlace`” with its real manager/substrate ownership.

## 3. Manager target architecture

Keep `PDV__ManagerQuest` as the single orchestration host: startup, one update chain, dawn ordering, module wiring, and debug dispatch. Move implementation into these deep modules:

- `PDV_DevotionLedger`: piety, tiers, patron state, Broad Pantheon Pools, Logical Devotional Act aggregation, neglect selection, dawn progression, and CK mirror globals.
- `PDV_OriginRuntimeBase` plus ten race adapters: race properties, substrates/relation ledgers/state interpretation, rites, contextual signals, rewards, and Survey fragments. The manager selects one adapter by birth race and contains no race switchboard.
- `PDV_QuestReactionRuntime`: ingress compaction, persisted FIFO, matrix/meta lookup, duplicate suppression, slice processing, surface accumulation, and completion markers.
- `PDV_ContextualFavorRuntime`: eligibility, the one-active-favor rule, application, expiry, clearing, and status. It receives cadence from the manager and owns no timer.
- `PDV_DaedricRuntime`: shared pact, price, stigma, offer, and dawn coordination only. Prince-specific behavior remains in the existing path scripts.
- `PDV_PrismaPresenter`: bounded toast/panel/Book construction and journal-ring ownership. `PDV_PrismaBridge` remains the native adapter.
- Generated `PDV_DevotionRules` plus small leaf Globals for stateless rules/helpers where extraction produces real depth.

Deepen `PDV_EventBus` to a small set of engine-family routes plus one curated signal route. Dispatch each event once to the ledger, active origin adapter, and eligible Daedric path. Remove race-specific forwarding wrappers after all source, fragment, and compatibility callers move.

Papyrus has no formal interface type, so module contracts are base-script functions with a compile-order manifest. Build from an empty PEX output in this dependency order:

1. leaf Globals, event types, rules, and helpers;
2. deity, track, substrate, and path bases;
3. ledger and runtime modules;
4. race adapters;
5. EventBus, routers, and PlayerEvents;
6. manager;
7. MCM;
8. fragments and compatibility scripts.

Stable interfaces:

- preserve all twelve native Papyrus functions;
- preserve Prisma toast, panel, overlay, and Book payload schemas and close behavior;
- preserve one manager-owned update chain;
- preserve route ownership and existing player-visible mechanics unless the retirement ledger explicitly says otherwise.

## 4. Parallel, token-efficient execution

After bootstrap, use isolated worktrees and three parallel ownership lanes:

- **Record retirement lane:** retirement ledger, direct batched houseCARL reverse-reference proof, ESP deletion, VMAD/FormList cleanup, SEQ regeneration, and retained-attachment comparison.
- **Papyrus architecture lane:** manager extraction, race adapters, EventBus rerouting, dead-function removal, clean compilation, and profiler comparison.
- **Contracts/release lane:** ADR/docs, generator and manifest changes, verifier negative assertions, exact payload inventory, Prisma/native contract snapshots, and packaging.

Efficiency rules:

- agents return ledger deltas and proof results, not duplicate narrative reports;
- batch houseCARL reads by plugin/type and cache exact FormKeys;
- generate verifier, compile inventory, and package expectations from authoritative manifests;
- keep commits domain-atomic so failed runtime lanes can be reverted independently;
- do not preserve compatibility wrappers or migrations solely to make deletion order easier;
- do not accept line-count reduction as optimization without correctness or runtime evidence.

Likely overnight work:

- branch/ADR/retirement authority;
- stale scaffold manifests and verifier conversion;
- generic SacredPlace topology removal;
- four legacy state tracks;
- `DeityDomain`, eleven message properties, Altmer duplicate bindings, and proven dead functions;
- manifest-derived script/archive counts and refreshed houseCARL proof.

Longer proof work:

- manager and EventBus decomposition;
- exact MGEF retirement;
- reserved curated-signal implementation;
- all-race fresh-game regression;
- deterministic profiler comparison and release closeout.

## 5. Acceptance and release

### Static and compile

- Compile all active scripts from empty output with zero warnings/errors.
- Enforce manager-before-MCM and MCM freshness against manager source and bytecode.
- No circular module dependency.
- No retired identifier appears in PSC, PEX, VMAD, FormLists, active manifests, verifier rules, or runtime lookup strings.
- Manager contains orchestration rather than race implementations, quest matrices, generated rule tables, or Prisma/Book construction. A 50% size reduction is a useful indicator, not a ship gate.

### houseCARL readback

- `Devotion.esp` active in `Devotion V3 Dev` (the V3 profile/mod folder `Devotion-V3Dev`).
- Zero missing masters, dangling links, or parse failures.
- Every retired FormKey absent and every retained/replacement owner present.
- Exact expected VMAD attachment/property delta with no accidental attachment loss.
- Critical winners and both contested CELL nested Devotion references unchanged.
- Fresh ESP hash, record counts, SEQ, and ANAM proof.

### Fresh-game runtime

- Initialize and exercise all ten origins.
- Prove startup, MCM, shrine, piety/tier/patron, broad/focused worship, sleep/location/combat/crafting, curse, Daedric, neglect, contextual favor, and dawn ordering.
- Prove Argonian Bed-of-Choice/adaptation and Orc Hearth-Held/Trial of Iron after extraction.
- Prove Breton Hidden Art Prince responses remain while duplicate price/stigma stays suppressed when appropriate.
- Four quest-reaction jobs complete FIFO with matching surfaces and no toast later than two seconds; organic MQ106 also passes.
- Survey, Book of Days, Prisma panel/toasts, and close behavior remain correct.
- Zero PDV errors, missing-script/property warnings, stack dumps, VM freezes, queue overflow, broad-scope aborts, or duplicate route ownership.

### Performance and package

- Compare deterministic idle and active profiler runs against the branch baseline.
- No additional recurring timer; idle external calls must not regress.
- Hot-path changes require either a proven defect removal or at least 20% fewer targeted external calls.
- Derive PSC/PEX and archive counts from the exact release manifest; remove hardcoded 96/216 assumptions.
- Rebuild from final live state, reopen the archive, compare every entry, and publish count, size, SHA-256, proof buckets, and remaining manual debt.

The 2.0 release is ready to ship only when authority, compile/static, houseCARL readback, fresh-game runtime, manual presentation, performance, and release-package buckets all pass independently.


## 6. Housekeeping / ESP cleanup debt (tracked)

### Strip the stale property fills off the manager QUST

**Observed live 2026-08-19/20** on a fresh Nord save (Papyrus.0.log): a block of
`Property <X> on script pdv__managerquest ... cannot be initialized because the script no
longer contains that property` warnings on `PDV__ManagerQuest (00C325)`. These are orphaned
VMAD property FILLS left on the manager QUST after earlier extraction phases moved the
properties into other module scripts. Verified: for each sampled name the property is now
declared on the LEDGER script, not the manager (`manager=0, ledger=1`), and no Phase A/B/C
commit removed a manager property -- so this is pre-existing extraction debt, not a rebuild
regression.

Affected fills seen so far (non-exhaustive): deity refs `PDV_Kynareth`, `PDV_Dibella`,
`PDV_Stendarr`, `PDV_Akatosh`, `PDV_Zen`; piety/patron globals `PDV_GLO_ActivePiety`,
`PDV_GLO_ActiveDeityIndex`, `PDV_GLO_PatronState`, `PDV_GLO_PatronDeity`; disfavor spells
`PDV_SPEL_Disfavor_*`; plus `PDV_FLST_AllDeities`, `PDV_ModePresetRef`, `WarlockFaction`,
`necromancerFaction`. Matches the earlier estimate of ~34 stale fills / ~198 warnings.

- **Impact:** harmless at runtime (the fill is ignored; the property works from its real home
  on the ledger QUST -- Status/Book/piety all render correctly), but it directly violates the
  section-5 acceptance criterion "zero missing-script/property warnings," so it must be cleared
  before that bucket can pass.
- **Action (supervised ESP write, D10):** for the `PDV__ManagerQuest` QUST VMAD, remove every
  property fill whose name is no longer declared on the current `PDV__ManagerQuest.psc`. Derive
  the keep-list from the live script's property declarations; delete only the orphans. Do the
  same sweep for any other host QUST that carries fills for since-moved properties.
- **Verify:** houseCARL readback of the manager QUST VMAD shows only in-script properties;
  a fresh-save Papyrus log shows zero "cannot be initialized" warnings for `pdv__managerquest`.
- **Status:** STATIC CLOSED 2026-08-20 -- direct houseCARL consolidation removed 35 undeclared
  fills plus 25 later identical-name duplicates (60 removals total). The manager now has 455
  unique properties, zero undeclared fills, and zero duplicate names; extracted module references
  remain filled. `pdv_vmad_audit.mjs` now derives the full VMAD range, refuses partial evidence,
  and independently fails on undeclared or duplicate properties. Fresh-game Papyrus-log proof
  remains part of the runtime acceptance pass.
