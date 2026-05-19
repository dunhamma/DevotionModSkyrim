# PAPYRUS_KNOWLEDGE_INTAKE — Phase 3 Design Input

**Status:** LIVING design input. NOT a locked decision. Authored 2026-05-02 during Aaron prep-workspace conversation. **Spike findings appended 2026-05-02** — see §11; spike outputs at [dev/papyrus-spike/](dev/papyrus-spike/) (artifacts to be archived as ARCHIVE per HOUSECARL_DOC_HYGIENE.md §2.1 at Phase 3.6 absorption commit; until then the spike directory is a LIVING workbench Phase 3.6 author may re-run or extend).
**Scope:** Design input for **Phase 3.6 (AD-3/AD-4 skill cluster)**. Specifically informs how the `knowledge-file-authoring` specialist will produce Papyrus API reference content for the bundled skill cluster.
**Depends on:** Q5 (3-meta-skill cluster), Q9 (BSArch wrapper amendment to AD-1), Q12 (SKSE source READ at v1.0), Q3 (no silent wrong answers + eval discipline).
**Awaits:** Aaron review + Phase 3 sub-phase planning. Treat as proposal until then.

---

## PDV Practical Parser Notes

These project-local rules come from the 2026-05-14 external Skyrim modding lessons intake and should be treated as authoring guardrails alongside API-source verification:

- Papyrus string literal escapes are very limited. Use only `\\` and `\"`; do not write `\n`, `\r`, or `\t` into `.psc` strings.
- Papyrus docstring blocks (`{...}`) belong immediately after `ScriptName`, `Property`, `Function`, or `Event` declarations only. Do not place them inside control flow, and do not paste JSON-like examples with literal `{` inside docstrings.
- `StringUtil` has no built-in `Replace`. Avoid string substitution in hot paths; if needed, implement and compile-test a manual scan/rebuild helper.
- Papyrus lacks several familiar conveniences: no ternary operator, no string interpolation, no string `+=`, no `Math.max`/`Math.min`, no variable-sized arrays, and arrays cap at 128 elements. Treat local arrays inside functions as suspect if compile output or behavior looks stale.
- Split chained casts into separate variables; chained forms such as `(value as int as float)` are not safe Papyrus.
- Avoid short local/property names that collide with script or type names. Known pain includes `key`, `form`, `actor`, `cell`, `ActorBase`, and `Message`; prefer explicit names such as `targetActor` or `targetForm`.
- Local variables cannot safely shadow script properties. If a property such as `PlayerRef` exists, use it directly or choose a distinct local name.
- `Utility.Wait()` inside paused UI/input paths resumes only when the game unpauses, which can release queued duplicate handlers in a burst.
- Topic Info fragments compile in a narrow CK-bound scope. Prefer quest properties the CK can auto-bind, and avoid assuming a fragment can directly see manager script variables.
- CK condition function names are not always Papyrus method names. Example: Papyrus `IsDead()` corresponds to CK condition `GetDead`; verify both sides before writing CK instructions.
- For hold/location work, avoid unverified convenience methods. `Cell.GetCurrentLocation()` and vanilla SSE `Location.IsContainedIn()` are not safe assumptions, and `Location.HasCommonParent()` is too broad for hold detection. Prefer walking parent locations against CK-bound hold `Location` properties.
- `cqf`/CallQuestFunction only calls named quest script functions. PDV's validated debug path remains the `SetPQV` poll harness unless a new named-function dispatcher is deliberately added.
- Retest script behavior from a new game or main-menu `coc qasmoke` path when save-baked state may be masking the current source.
- Pick one persistence backend per key. Do not read a key through JFormDB if writers use StorageUtil, or vice versa. For long-lived JArray/JDB collections, store integer FormIDs and resolve with `Game.GetForm()` instead of storing Actor/Form objects directly.

## Papyrus Runtime And Save Hygiene Rules

These rules come from the 2026-05-19 `papyrus-scripting-cache.md` intake. They
are practical hygiene rules for writing PDV Papyrus that survives real saves,
heavy modlists, and update cycles.

### Prefer engine data before Papyrus

- Use CK conditions, quest/package/scene fragments, aliases, linked refs,
  default scripts, perks, spells, magic-effect conditions, and plugin data before
  adding custom Papyrus.
- Papyrus should be event-driven glue: receive a meaningful event, validate it,
  call a small API, store deliberate state, and exit.
- Do not use Papyrus to emulate a condition, package, FormList, keyword, or
  magic-effect archetype that the engine can already evaluate.

### Events, timers, and polling

- Prefer events over polling.
- Prefer `RegisterForSingleUpdate` / `RegisterForSingleUpdateGameTime` chains
  over perpetual `RegisterForUpdate`, unless a true periodic service is required
  and is always unregistered.
- Register the next single update at the end of the handler, after deciding the
  loop should continue.
- Every loop/timer must have a known exit: quest stop, effect finish, alias
  clear, target death, object unload, dependency loss, timeout, or max
  iteration.
- Avoid long `Utility.Wait()` / `WaitGameTime()` workflows. Latent waits are
  imprecise, keep the running object persistent, and can resume after queued
  state has changed.

### Queueing and re-entrancy

- Papyrus has one active thread per script instance; other events queue behind
  it, but external calls can release the script lock and allow another queued
  event to enter.
- Do not assume state remains unchanged after calling another script/object,
  reading/writing another object's property, waiting, opening UI, or calling a
  latent/native path.
- Use states, busy flags, version tokens, or explicit queues when overlapping
  events can hit the same object.
- Keep event handlers and functions short; split large work across bounded
  updates or manager-owned queues.

### Reference persistence

- CK-filled `ObjectReference` and `Actor` properties, script variables pointing
  at refs, long-running functions, and registered events can keep references
  persistent.
- Prefer aliases, linked refs, event arguments, local variables, and FormLists
  over permanent reference properties.
- `Actor Property PlayerREF Auto` remains acceptable because the player is
  already persistent and repeated `Game.GetPlayer()` calls are worse in hot
  paths.
- Clear temporary reference variables to `None` when their work is complete.
- Unregister updates/events as soon as they are no longer needed.
- Treat mass script attachment to base objects, many refs, many actors, or many
  active effects as high-risk unless the event surface is tiny and cleanup is
  proven.

### Form lookup and optional dependencies

- Use CK-filled properties for forms owned by PDV or hard dependencies.
- Reserve `Game.GetFormFromFile` for optional dependencies, rare dynamic lookup,
  or prototypes that will be converted before release.
- If `Game.GetFormFromFile` is unavoidable, resolve once, cache, guard for
  `None`, and never call it inside frequent loops or updates.

### Runtime errors are bugs

- `None` calls, bad casts, stale properties, missing scripts, type mismatches,
  and unloaded-cell warnings are not harmless log noise.
- Guard every optional form/ref/cast before use.
- Avoid `Cast` / `RemoteCast` from unloaded refs; delay until the source and
  target are in a valid loaded state or use an engine-safe route.
- Fix recurring Papyrus warnings from PDV scripts before interpreting gameplay
  behavior. Log spam can hide the real bug and increase VM load.

### Save-update safety

- Treat a Skyrim save as a stateful Papyrus database.
- Saves can remember script instances, property/variable values, running stacks,
  dynamic FormList changes, and old functions that were running when the save
  was made.
- Adding variables/properties is safer than renaming/removing them. A rename is
  effectively delete plus add.
- Do not rely on `OnInit()` rerunning for existing saved instances.
- Changing a property value in the plugin may not overwrite an already-saved
  value.
- Removing scripts/properties from plugin VMAD does not guarantee old saved
  instances disappear.
- For update-safe scripts, use an integer version, run idempotent migration from
  a load/timer path, stop old timers, unregister old events, and leave
  compatibility shutdown code when abandoning old behavior.
- Do not promise safe mid-save uninstall unless the mod intentionally stops
  quests, unregisters events, clears aliases, removes added spells/perks/items
  where appropriate, and shuts down timers.

### Profiling and INI discipline

- Profile before guessing. Papyrus timing is non-intuitive.
- Use Papyrus logging for development/diagnosis, not as a permanent user
  requirement.
- Use `DumpPapyrusStacks` / `DPS`, `StartPapyrusScriptProfile` / `StartPSP`, and
  script-side profiling only when the relevant INI flags are enabled for a
  controlled test.
- Do not "fix" PDV by advising huge Papyrus INI budget or memory increases.
  CK-derived documentation treats those settings as tradeoffs that can hurt
  frame time, memory behavior, or stack stability.
- Papyrus Tweaks NG and similar engine-tweak plugins are not permission to write
  sloppy Papyrus.

### Review checklist additions

Before accepting a PDV Papyrus script, also ask:

- Can this be CK data, a condition, a magic effect, an alias, a linked ref, a
  quest stage, or a default script instead?
- Is every repeated update a single-update chain or a justified, unregistered
  periodic service?
- Does every loop/timer have a stop condition?
- Are all optional refs/forms/casts guarded?
- Are ref properties avoided unless the target is intentionally persistent?
- Are temporary refs cleared?
- Are events unregistered on shutdown/effect finish/quest stop?
- Is `PlayerREF` a property when the player is accessed repeatedly?
- Is `Game.GetFormFromFile` absent from hot paths?
- Are removed/renamed properties and VMAD changes treated as save migrations?
- Could the script behave correctly if events fire twice, out of order, or after
  a wait?

---

## 1. Why this exists

Q12 pulled SKSE source READ into v1.0 as a free byproduct of file-level VFS (Q7). Once Claude can read user-modlist `.psc` files, every script Claude reads will be calling Papyrus functions defined in some combination of:

- Vanilla Papyrus (Bethesda's shipped scripts, sourced from CK Wiki)
- SKSE-provided extensions (`StringUtil`, `Math`, `Input`, extended methods on `Form`/`Actor`/etc.)
- Third-party SKSE plugins (PapyrusUtil, JContainers, RaceMenu, MCM Helper, etc.)

Without API reference for those layers, Claude is reading code with half the symbol table missing. Q3's "no silent wrong answers" makes this worse than absence — Claude must not invent plausible-but-wrong function signatures. Bundled API reference is the answer.

The authoritative public reference site for Papyrus is **[papyrus.bellcube.dev](https://papyrus.bellcube.dev/)** — a curated index covering vanilla, SKSE, and 45 third-party SKSE plugins for SkyrimSE (plus FO4 and Starfield ecosystems). This document covers how Housecarl will ingest that corpus into its skill bundles.

---

## 2. Source corpus

**Repo:** [BellCubeDev/papyrus-index](https://github.com/BellCubeDev/papyrus-index)
**Stack:** Next.js 16 / TypeScript / pnpm. Custom Papyrus parser + CK Wiki + GitHub-wiki integration.
**Maintainer:** Single dev (BellCube). 7 stars. Last commit ~2 months pre-conversation. Hobby-tier project — flagged as upstream-stability risk.

### 2.1 Data shape

| Game | Source dirs | Files | Bytes |
|---|---|---|---|
| **SkyrimSE** | 47 | 389 | 1.67 MB |
| Fallout4 | — | 149 | 555 KB |
| Starfield | — | 110 | 370 KB |

**SkyrimSE breakdown:** 246 `.psc` files (Papyrus source declarations) + 48 `meta.yaml` (per-source metadata) + 42 `LICENSE.txt` + a few support files. Plus build-time fetches from CK Wiki and several mod-authors' GitHub wikis (PowerOfThree, SkyUI, etc.).

### 2.2 Source-dir tier inventory (SkyrimSE)

**Universal-need tier:**
- `vanilla` — Bethesda's shipped scripts, sourced from CK Wiki
- `skse` — SKSE-provided Papyrus declarations (`StringUtil`, `Math`, `Input`, extended methods)

**Popular SKSE-plugin tier (auto-install when matching plugin present in modlist):**
- `papyrusutil`, `jcontainers`, `racemenu`, `mcmhelper`, `consoleutil`, `dyndolod`, `po3` (PowerOfThree's stable), `skyui-sdk`, `custom-skills`, `experience`, `iequip`, `immequipdisp`, `inventoryfunctions`, `perkentrypoint`, `sppbridge`, `spellhotbar`, `skyregex`, `skyprompt`

**Library tier (auto-install when matching plugin present):**
- `clib`, `libfire`, `libmathf`, `libturtleclub`

**Niche/long-tail tier (auto-install when matching plugin present):**
- `andrealphus`, `atweaks`, `caco`, `cube`, `currency-swapper`, `dylbills`, `dynamicwetness`, `dynanimcast`, `fisses`, `fuzzyactorsearch`, `iniman`, `messagebox`, `morehud`, `morehudinv`, `ollama`, `paper`, `rogue`, `scrab`, `shazdeh`, `simplyknock`, `steelfeathers`, `trashutil`, `yasoultrapman`

### 2.3 Coverage gaps (be honest)

- **Curated, not exhaustive.** Thousands of SKSE plugins exist; this corpus has ~47 SkyrimSE sources. The most-depended-on are present; obscure or brand-new plugins are not.
- **`.psc` source only.** No `.pex` decompilation. Mods that ship only `.pex` (no source) are not in the corpus and won't be without a separate decompile pipeline (Champollion-style). Per Aaron 2026-05-02: `.pex` reading is **explicitly out-of-scope for v1.0**. Mods either ship source or they don't.

### 2.4 Licensing

- **Website code:** MIT (BellCube 2024).
- **`data/` folder:** explicitly carved out — *"These files are owned by their respective authors and are included under their respective licenses and/or fair use."* Per-source `LICENSE.txt` where available; some have none.
- **Implication for Housecarl distribution:** distilled API surface (signatures + brief descriptions, attributed) is on firmer fair-use ground than redistributing raw `.psc` files verbatim. The transform step in our pipeline naturally produces distilled output.

---

## 3. Decision: Option C (vendor BellCube's parser) with Option B as documented fallback

### 3.1 Recap of options considered

- **A. Bundle raw `.psc` verbatim** — minimal effort but poor format for skill bundles, and licensing for verbatim redistribution is per-source-uncertain. Rejected.
- **B. Write our own parser from scratch** — emit normalized markdown directly. Manageable for `.psc` signature parsing alone, but to match BellCube's feature set (CK Wiki commentary, GitHub-wiki integration, inheritance aggregation, indexed cross-references) would require rebuilding MediaWiki scraping, GitHub wiki crawling, and inheritance resolution. Becomes substantial.
- **C. Vendor BellCube's parser** — use their proven, multi-worker, modular parser plus their wiki-integration scripts. Consume the JSON they emit; transform JSON → markdown for our skill bundle.

### 3.2 Why C wins (revised analysis)

| | B (own parser) | C (vendor theirs) |
|---|---|---|
| `.psc` signatures | ✓ | ✓ |
| CK Wiki commentary | ✗ unless we build a MediaWiki scraper | ✓ already wired |
| GitHub wiki commentary | ✗ unless we build a wiki crawler | ✓ already wired |
| Inheritance aggregation | ✗ unless we write it | ✓ already done |
| Per-source metadata handling | ✗ implement | ✓ |
| Build pipeline cost | Whatever language Phase 3 picks | Node 22+, pnpm, tsx, ~80+ npm deps |
| Maintenance posture | Own everything | Track upstream; fork if abandoned |
| Switching cost later | N/A — already own it | Re-do as B at fallback time (cost bounded) |

The fall-back to B is bounded: at worst we eventually do the work proposed for B today, just later when we know more about which edge cases actually matter. Meanwhile we get the wiki commentary and inheritance resolution for free.

### 3.3 Trigger conditions for falling back to B

Switch to Option B when **both** are true:
1. Upstream `BellCubeDev/papyrus-index` has gone >12 months without commits (or maintainer publicly archives), AND
2. We discover a real gap or bug in the corpus we need to fix ourselves and can't reasonably patch upstream.

Until both are true, stay on C with a pinned upstream commit.

---

## 4. Concrete C plan

1. **Vendor `BellCubeDev/papyrus-index`** as a git submodule or pinned source dependency under `dev/` of the eventual Housecarl repo. Not user-facing — build-time only.
2. **Strip the front-end build path.** Add a `parse-only` build profile that runs `pnpm install --filter parser` (or equivalent narrow install) and `pnpm run parse:and-index`, then stops before `next build`. Skip Next.js, React, FontAwesome, and the rest of the web-rendering deps.
3. **Consume the generated JSON.** Their `parse-or-load-all.ts` produces it; per their `parse:reset` script, the cache lives at `public/raw.json`. (Verify exact path during Phase 3.6 spike.)
4. **Write the transform layer.** JSON → markdown skill-bundle files in our format. Same code in B and C; this is the part we own regardless. Probably ~200–400 lines in whichever language Phase 3 picks.
5. **Pin a known-good upstream commit.** Bump on a deliberate cadence (Housecarl release schedule), not auto-pull. If BellCube goes dormant, the pinned snapshot keeps working indefinitely.
6. **Document the fallback path.** Triggers in §3.3; B implementation sketch held in this doc as a future-session reference.

---

## 5. Pipeline detail: from `.psc` to skill bundle

### 5.1 High-level flow

```
                     SOURCE
   ┌──────────────────────────────────────────┐
   │  data/SkyrimSE/<source>/<Script>.psc     │  Raw Papyrus declarations
   │  data/SkyrimSE/<source>/meta.yaml        │  Per-source metadata
   │  cache/github-wikis/<source>/            │  Mod-author wiki content
   │  CK Wiki (fetched via parsoid-service)   │  Vanilla + SKSE commentary
   └──────────────────────────────────────────┘
                       ↓
              [BellCube's parser]
                       ↓
                STRUCTURED JSON
   ┌──────────────────────────────────────────┐
   │  Per-script: name, source, parent,       │
   │              functions[], properties[],  │
   │              structs[], events[]         │
   │  Per-function: name, returnType, params, │
   │                flags, doc, wikiContent,  │
   │                examples                  │
   │  Cross-refs: inheritance chains, overrides│
   └──────────────────────────────────────────┘
                       ↓
              [Housecarl transform layer]
                       ↓
                MARKDOWN KNOWLEDGE FILES
   ┌──────────────────────────────────────────┐
   │  references/vanilla/Actor.md             │
   │  references/vanilla/Form.md              │
   │  references/skse/StringUtil.md           │
   │  references/papyrusutil.md               │
   │  ...                                     │
   │  SKILL.md  (entry + function index)      │
   └──────────────────────────────────────────┘
                       ↓
              [Skill bundle packaging]
                       ↓
                INSTALLED SKILL
   ┌──────────────────────────────────────────┐
   │  .claude/skills/papyrus-reference/       │
   │     SKILL.md                             │
   │     references/...                       │
   └──────────────────────────────────────────┘
```

### 5.2 Worked example: `PapyrusUtil.PushString`

**Input** — from `data/SkyrimSE/papyrusutil/PapyrusUtil.psc`:

```papyrus
;/ Append a value to the end of the given array and return the new array.
   Performance: do not use in tight loops. /;
String[] Function PushString(String[] akArray, String asValue) Native Global
```

**After parser** — JSON record (illustrative shape; actual schema in their `data-structures/pure/function.ts`):

```json
{
  "script": "PapyrusUtil",
  "source": "papyrusutil",
  "function": {
    "name": "PushString",
    "returnType": {"name": "String", "isArray": true},
    "parameters": [
      {"name": "akArray", "type": {"name": "String", "isArray": true}},
      {"name": "asValue", "type": {"name": "String"}}
    ],
    "flags": ["Native", "Global"],
    "documentation": "Append a value to the end of the given array and return the new array.\n\nPerformance: do not use in tight loops.",
    "wikiContent": null
  }
}
```

**After our transform** — entry in `references/papyrusutil.md`:

```markdown
### `PushString(akArray, asValue) → String[]`

**Source:** PapyrusUtil  •  **Flags:** Native Global

Append a value to the end of the given array and return the new array.

> ⚠ **Performance:** do not use in tight loops.

**Parameters**
| Name | Type |
|---|---|
| `akArray` | `String[]` |
| `asValue` | `String` |
```

**SKILL.md index entry** (compact, always loaded):

```
PushString → references/papyrusutil.md
```

### 5.3 Why structured JSON is the load-bearing intermediate

Without the parser's JSON intermediate, our transform is brittle text-munging. With it:

- **Mechanical formatting.** Every function entry has the same headers, same parameter table, same flag rendering. No regex pile-up.
- **Cross-reference indexes.** "Functions that take `Actor` as a parameter" is `jq` against the JSON, not grep across `.psc` text.
- **Tier filtering.** "Generate skill files for vanilla + skse + only the plugins in this user's modlist" is a JSON filter, not a manual selection step.
- **Inheritance resolution.** "What methods does `Actor` actually have, including inherited from `ObjectReference` and `Form`?" is precomputed in the JSON aggregation, not something our transform has to re-derive.
- **Stable schema across regenerations.** Upstream parser bumps may improve coverage; our transform stays unchanged as long as their JSON schema is stable.

---

## 6. Knowledge-file format (proposed for Phase 3.6)

### 6.1 File layout in skill bundle

```
.claude/skills/papyrus-reference/
  SKILL.md                              ← entry, function index, usage rules
  references/
    vanilla/
      Actor.md
      Form.md
      ObjectReference.md
      Quest.md
      ...
    skse/
      StringUtil.md
      Math.md
      Input.md
      Form.md                           ← SKSE additions to Form
      ...
    papyrusutil.md                      ← single-script sources flat
    jcontainers.md
    racemenu.md
    ...
```

### 6.2 SKILL.md structure (sketch)

```markdown
# Papyrus API Reference

When reading or writing Papyrus (.psc) scripts, consult per-script reference files
under `references/` for function signatures, parameters, return types, and docs.

## Function index

(Compact name → file lookup, ~5–15 KB total. Always loaded with skill.)

PushString          → references/papyrusutil.md
PopString           → references/papyrusutil.md
GetActorValue       → references/vanilla/Actor.md
SetActorValue       → references/vanilla/Actor.md
JsonObj             → references/jcontainers.md
StringUtil.Substring → references/skse/StringUtil.md
...

## Usage

- Look up a function by name in the index, then Read the referenced file.
- Multiple matches → check source qualifier (PapyrusUtil.PushString vs ArrayUtil.PushString).
- Function not found in index → either the user's modlist depends on a plugin
  not bundled, OR the function doesn't exist. Don't invent signatures (Q3:
  no silent wrong answers).
```

### 6.3 Per-script reference file shape

One markdown file per script. Top section: script metadata + inheritance chain. Body: one entry per function/property/event/struct, sorted alphabetically. Section headers for grouping (Functions, Global Functions, Properties, Events, Structs).

This format is exactly what the `knowledge-file-authoring` meta-skill (Q5) should produce for any reference-style domain. The Papyrus reference skill becomes the **prototype/template** for that meta-skill's output shape.

---

## 7. Tier strategy

| Tier | When installed | Sources |
|---|---|---|
| **1. Always** | Default install | `vanilla`, `skse` |
| **2. Conditional** | Auto-installed when matching SKSE plugin DLL detected in active MO2 modlist | All other SkyrimSE source dirs (PapyrusUtil, JContainers, RaceMenu, MCM Helper, …) |
| **3. Optional** | Manual install or non-Skyrim Housecarl user | Fallout4, Starfield |

The `modlist-authoring` skill (Q5 router) already knows what's in the user's modlist; it can drive the Tier 2 install decisions when the skill cluster is initialized or when the modlist changes. Tier 1 is unconditional: every modern Skyrim modlist has SKSE.

**Footprint sketch:** Tier 1 distilled is probably ~200–300 KB of markdown. Each Tier 2 source is 5–50 KB. Tier 3 omitted from default Skyrim install. Negligible on disk.

---

## 8. Resolved + open design questions

### 8.1 Resolved by Aaron 2026-05-02

- **Q-PA-1 — Build-time vs install-time generation: BUILD-TIME, pre-packaged.** Run the parser in Housecarl's CI; ship pre-generated markdown as part of installer payload. User machine never runs the parser, never has Node installed, never makes network calls during install. Reasons: (a) no Node toolchain dependency on modder machines, (b) Q3 eval discipline requires testing the *actual artifact users receive* — install-time generation defeats this, (c) reproducibility — every install bit-identical, (d) Papyrus API stability means "freshness per install" isn't valuable; bumping per Housecarl release is sufficient.
- **Q-PA-2 — Conditional Tier 2 mechanism: SHIP ALL, GATE AT LOAD.** Bundle all Tier 1 + Tier 2 reference files in the Housecarl installer; let skill-load logic gate by modlist scan at runtime. Don't dynamically install/uninstall files. Reasons: consistent with Q-PA-1 pre-build model; total Tier 1 + Tier 2 footprint is sub-MB; skill-load filtering is cheaper than file-system mutations; matches the "skill index always loaded, per-script files loaded on demand" pattern.
- **Q-PA-7 — Knowledge-pack update cadence between Housecarl releases: WAIT FOR NEXT HOUSECARL RELEASE.** No mid-release update mechanism for v1.0. Knowledge pack refreshes only when a new Housecarl version ships. Reasons: simple, predictable, no separate update infrastructure; Papyrus API stability + popular-plugin-coverage in BellCube's corpus means stale-pack risk between releases is low; consistent with Q-PA-1 pre-build / single-artifact model. Trade-off accepted: user who installs a brand-new SKSE plugin after their Housecarl install gets no API reference for it until the next Housecarl release. Options (b) separately-versioned knowledge pack and (c) live WebFetch fallback remain viable v1.x improvements but are not in v1.0 scope. Note: Q-PA-3/Q-PA-4 layered fallback (live WebFetch on bundled-corpus miss, then explicit warning) partially mitigates this — single missing functions can still resolve via WebFetch even between Housecarl releases.
- **Q-PA-3 + Q-PA-4 — Coverage-gap behavior: LAYERED FALLBACK.** When Claude needs a Papyrus function reference: (1) look up in bundled skill index → use if found. (2) If not found, attempt live WebFetch against papyrus.bellcube.dev for that specific function. (3) If WebFetch also misses, **explicit warning to user**: "no Papyrus reference for `FunctionName` — bundled corpus and live lookup both came up empty. Will not invent a signature." Per Q3 ("no silent wrong answers"), Claude must never invent signatures when reference is missing — the layered ladder gives every reasonable chance to find the function before giving up. WebFetch is acceptable here (vs the rejection of WebFetch as a *primary* source in §1) because it's a targeted single-function lookup on a documented gap, not a per-session-every-lookup tax.
- **Q-PA-5 — Papyrus skill build approach: HAND-BUILT PRECURSOR.** Build the Papyrus reference skill by hand for v1.0 — write the JSON-to-markdown transform layer specifically for Papyrus, ship it as a one-off skill. The `knowledge-file-authoring` meta-skill (Q5) is built later (v1.x), at which point it absorbs the Papyrus skill's pattern as a known template for any reference-style domain. Reasons: lower bootstrap risk (concrete example before abstraction); the meta-skill emerges from real worked experience rather than abstract design; v1.0 timeline pressure favors solving one problem well over trying to solve a generic problem we don't yet fully understand.
- **Q-PA-6 — Upstream version handling: ALWAYS-LATEST AT BUILD TIME, LOG THE COMMIT.** Housecarl CI clones BellCube's `papyrus-index` fresh at each release-build, uses whatever is current at the top of `production` branch, and records the resolved commit hash in the Housecarl release changelog for traceability. No formal pinning, no separate "bump" maintenance step. Reasons: Housecarl is small-scale; the user never sees BellCube's repo (Q-PA-1 already shipped pre-built markdown to user); two builds on the same day produce identical output anyway; commit-hash logging in changelog gives debugging traceability if a knowledge-pack bug surfaces later. If upstream ever ships a regression that reaches a Housecarl release, the fix is to re-cut the release with an older BellCube commit pinned for that one build — no ongoing pin-management infrastructure needed for the common case.

### 8.2 Open for Phase 3.6

*All Q-PA-1 through Q-PA-7 resolved 2026-05-02. No open questions remaining at the design-input layer; remaining work is implementation-time spike-and-validate during Phase 3.6.*

---

## 9. Bonus: incidental finds in BellCube's repo

Worth noting separately because they intersect other Housecarl decisions:

### 9.1 BSArch wrapper

`src/papyrus/scraping/download/BSArch.ts` — working TypeScript wrapper around BSArch CLI. Phase 3.5 will need a BSArch wrapper for Q9 (BSA support pulled into v1.0). Even if Phase 3 picks a non-TypeScript stack, this is **reference code worth studying** for argument forms, error handling, and edge cases.

### 9.2 Nexus Mods API integration

`src/papyrus/scraping/download/DownloadNeededMods.ts` uses the Nexus Mods API to fetch mod files for parsing. Possibly relevant if Housecarl ever needs to programmatically fetch mods — though that's not currently in v1.0 scope. Filed for awareness.

### 9.3 Architecture pattern: pure types vs indexed types

Their `data-structures/pure/` (raw type definitions) vs `data-structures/indexing/` (cross-referenced versions, with circular refs explicitly noted as non-serializable) is a clean pattern for any LLM-facing data layer Housecarl might build. Mentioned for Phase 3 architecture awareness.

---

## 10. Related Q-locks

This design is consistent with and depends on:

- **Q3** — No silent wrong answers + eval discipline. Bundled API reference reduces hallucinated function signatures; missing-function index entries surface as explicit gaps not invented signatures.
- **Q5** — 3-meta-skill cluster (`modlist-authoring` + `skill-authoring` + `knowledge-file-authoring`). Papyrus reference skill is a prototype output for `knowledge-file-authoring`; tier installation is driven by `modlist-authoring`.
- **Q9** — BSA via BSArch CLI wrapper. BellCube's BSArch wrapper is incidental reference material.
- **Q12** — SKSE source READ at v1.0. This is what makes API reference a v1.0 *requirement* not a nice-to-have.
- **Q13** — Phase 3 sequence. Papyrus knowledge intake lives in Phase 3.6 (AD-3/AD-4 skill cluster), depends on no earlier sub-phase deliverables.

No new Q-locks proposed by this doc. All decisions in §3 and §6 are subordinate to the existing locks; no re-litigation required.

---

## 11. Spike findings (2026-05-02)

Bounded parser-only spike run during Aaron's PAPYRUS_KNOWLEDGE_INTAKE.md review session, scoped to: validate Option C is real, smoke-test §6 format against actual data, surface format/data issues while design is still cheap to revise. Spike ≠ production; production transform is Phase 3.6 work.

### 11.1 Method

1. Cloned `BellCubeDev/papyrus-index` `production` branch shallow at commit **`77f530a39a49fc5e607342ead8fcdb866f98419b`** (last commit ~9 weeks before spike). Lives at [dev/papyrus-spike/upstream-clone/](dev/papyrus-spike/upstream-clone/).
2. Ran `pnpm install --ignore-scripts` via `corepack pnpm` (no global pnpm install needed; corepack ships with Node ≥16). 38 s wall-clock, ~588 MB / ~943 packages in `node_modules/.pnpm`.
3. Generated the JSON schemas (`SourceMetadata.schema.json`, `IgnoreYaml.schema.json`) by invoking `./node_modules/.bin/ts-json-schema-generator` directly (sidesteps the `pwsh`-shell prereq — see §11.4 below).
4. Ran the parser via `./node_modules/.bin/tsx ./src/papyrus/parsing/parse-or-load-all.ts`. After the dirent fix in §11.4, full parse of all three games completed in **~169 ms**, producing **`public/raw.json` ≈ 21 MB**.
5. Extracted three JSON samples (`vanilla/Actor`, `skse/StringUtil`, `papyrusutil/PapyrusUtil`) into [dev/papyrus-spike/json-samples/](dev/papyrus-spike/json-samples/) for transform input.
6. Wrote a throwaway transform script at [dev/papyrus-spike/scripts/transform.mjs](dev/papyrus-spike/scripts/transform.mjs) (~270 lines, JS) that consumes the three sample JSONs and emits the §6-format markdown into [dev/papyrus-spike/markdown-samples/](dev/papyrus-spike/markdown-samples/).
7. Helper scripts (`00`–`04` in `scripts/`) capture probes used along the way: `parseScriptSync` smoke-test, `dirent.path` Node-version probe, sample extractor, sample inspector, aggregate corpus stats.

### 11.2 Outputs

```
dev/papyrus-spike/
├── upstream-clone/               BellCubeDev/papyrus-index pinned at 77f530a (production)
│                                 — local patch in src/papyrus/parsing/parse-all-for-game.ts (see 11.4)
│                                 — node_modules/ NOT cleaned up; reproducible re-run lives here
├── json-samples/                 3 PapyrusScript JSON entries, one per chosen sample
│   ├── vanilla__actor.json          145 KB (200 functions, 19 events, 5 properties)
│   ├── skse__stringutil.json          9 KB (11 functions, all global natives)
│   └── papyrusutil__papyrusutil.json 95 KB (97 functions, all global natives)
├── markdown-samples/             §6-format output rendered from the JSON samples
│   ├── SKILL.md                  21 KB — function index for all 308 functions across the 3 samples
│   ├── PapyrusUtil.md            26 KB
│   └── references/
│       ├── skse/StringUtil.md     2.8 KB
│       └── vanilla/Actor.md       46 KB
└── scripts/
    ├── 00-smoke-test-parse.mjs   parseScriptSync smoke-test on PapyrusUtil.psc
    ├── 01-dirent-path-probe.mjs  Node 24 dirent.path-vs-parentPath verification
    ├── 02-extract-samples.mjs    pull 3 entries out of raw.json
    ├── 03-inspect-sample.mjs     print field shape of representative function/event/property
    ├── 04-aggregate-stats.mjs    SkyrimSE corpus stats (used in §11.5)
    └── transform.mjs             JSON → §6-format markdown (throwaway, NOT production)
```

### 11.3 What this validated

- **Option C is real.** BellCube's parser produces clean structured JSON with exactly the shape §3.2 / §5.3 anticipated (function name + flags + parameters with types + return type + documentationString + documentationComment; events as separate collection; propertyGroups with auto/get/set/hidden/const/mandatory + literal default values; struct collection present but empty for Skyrim as expected).
- **§6 markdown format converts cleanly from the JSON.** The transform script is mechanical: ~270 lines of JS for a complete renderer covering scripts, properties, events, global functions, instance functions, and structs. No regex pile-up; no edge-case-driven branching beyond the obvious type-discriminated-union switch in `renderType()`.
- **§5.2 worked example matches reality.** The actual `PapyrusUtil.PushString` parses identically to the illustrative JSON shape in §5.2. The §5.2 `wikiContent` field doesn't appear in the bare-parser output (that's an indexing/CK-Wiki layer — see §11.6).
- **Q-PA-1 (build-time pre-packaged) holds operationally.** The parser is fast enough (~169 ms cold parse) that running it in CI on every Housecarl release is trivial cost. Q-PA-6's "always-latest at build time" is workable.
- **Q-PA-5 (hand-built precursor) is well-bounded.** A production transform layer in this shape is ~300–500 lines in any sensible language. The spike's ~270-line throwaway covers the case completely. Phase 3.6 won't be writing thousands of lines of transform code.

### 11.4 What surprised us / known gotchas (all important for Phase 3.6)

1. **Upstream `dirent.path` Node-24 incompat.** [parse-all-for-game.ts:109](dev/papyrus-spike/upstream-clone/src/papyrus/parsing/parse-all-for-game.ts#L109) uses `dirent.path`, deprecated in Node 22 and **silently `undefined` on Node 24**. Symptom: parser succeeds without errors but every source emits empty `scripts: {}` because the per-script catch swallows the resulting non-PapyrusParserError filesystem failure. Fix is one character — `dirent.parentPath ?? dirent.path` — applied locally in the spike. Phase 3.6 should: (a) upstream the fix as a PR (good for BellCube; minimal-touch), and (b) **pin Node version explicitly** in the build pipeline (the doc just says "Node 22+"; the safe range right now is `node >= 22 < 24` unless we ship the patch upstream). Combined with Q-PA-6 ("always-latest at build time"), if BellCube hasn't merged the dirent fix at release time, the build pipeline either pins Node ≤22 or applies the patch as part of the build step.
2. **`script-shell=pwsh` in upstream `.npmrc`.** All `pnpm run *` scripts execute through PowerShell 7+ (`pwsh`), which is not Windows-default (Windows ships PowerShell 5.1 as `powershell`). On a system without `pwsh`, `pnpm run prepare:schemas`, `pnpm run parse:raw`, etc. all fail with a cryptic `ELIFECYCLE -4058`. Workarounds (any one suffices): install `pwsh` in the build environment; or override with `pnpm config set script-shell <bash-or-powershell-path>`; or invoke binaries directly via `node_modules/.bin/`. The spike used the third — production CI should pick whichever is most stable for the chosen runner.
3. **§4 step 2's `pnpm install --filter parser` doesn't apply.** Upstream is not a monorepo — there is no `parser` package to filter. The actual narrow install is **`pnpm install --ignore-scripts`** (skips husky, the parsoid `composer install`, and the GitHub-wiki clones), then run the parser binaries directly from `node_modules/.bin/`. **Doc §4 step 2 should be revised** by Phase 3.6 author.
4. **Upstream `prepare` scripts pull in non-Node dependencies.** The full `pnpm install` (without `--ignore-scripts`) tries to: (a) install husky git hooks (harmless but useless in a CI build), (b) `composer install` inside `parsoid-service/` (PHP/Composer dependency!), and (c) `git clone` three external GitHub wikis into `cache/github-wikis/`. None of these are needed for `.psc` parsing — only the indexing/CK-Wiki step needs them. `--ignore-scripts` cleanly skips all three; document this in Phase 3.6 build pipeline.
5. **Install footprint is not trivial.** ~588 MB / ~943 packages is a real CI-cost data point. Doc §3.2's "Node 22+, pnpm, tsx, ~80+ npm deps" understates this — `~80 declared` becomes `~943 transitive`. Cache aggressively in CI.
6. **`raw.json` is ~21 MB for the full SkyrimSE + FO4 + Starfield corpus.** Comfortable to commit as a build artifact, but not something to inline anywhere.
7. **Three SkyrimSE sources are empty in this snapshot:** `caco`, `iequip`, `racemenu` have `meta.yaml` but no `.psc` files yet (zero scripts, zero functions). All three are in §2.2's tiered list as if they had content. The Tier 2 modlist-driven gating logic must therefore tolerate "matching SKSE plugin present, but corpus has no `.psc`" and fall through to the layered fallback in Q-PA-3/Q-PA-4 (live WebFetch → explicit warning) rather than treating those gaps as "Claude knows the API."

### 11.5 Footprint reality check (revises §7)

Aggregate stats from the spike's [04-aggregate-stats.mjs](dev/papyrus-spike/scripts/04-aggregate-stats.mjs) output, SkyrimSE only:

| Metric | Count |
|---|---|
| Sources with content | 44 of 47 (3 empty: caco, iequip, racemenu) |
| Scripts | 246 |
| Functions | 6,035 |
| Events | 670 |
| Properties | 640 |
| Structs | 0 (Skyrim doesn't support `Struct` — expected) |
| Functions with official `documentationString` | 616 (10.2%) |
| Functions with line-comment `documentationComment` | 3,073 (50.9%) |

**Top sources by function count:** `skse` (1,562), `dylbills` (848), `vanilla` (749), `po3` (582), `papyrusutil` (537), `clib` (515), `jcontainers` (248), `immequipdisp` (113), `scrab` (101), `trashutil` (84).

**Footprint extrapolation from the 3 samples** (rendered §6 markdown, this spike's transform):

| | Functions | Markdown size | Bytes / function |
|---|---|---|---|
| `vanilla/Actor` | 200 fn + 19 ev + 5 prop | 46 KB | ~209 |
| `skse/StringUtil` | 11 fn (all globals) | 2.8 KB | ~257 |
| `papyrusutil/PapyrusUtil` | 97 fn (all globals) | 26 KB | ~265 |

Mean ≈ **~230 bytes / function** in §6 format with this transform. Applied to the corpus:

- **Tier 1 (vanilla 749 + skse 1,562) ≈ 540 KB** of distilled markdown. **Doc §7's "~200–300 KB" estimate is light by ~2×**; not catastrophic but worth correcting.
- **Tier 1 + Tier 2 (all 6,035 SkyrimSE functions) ≈ 1.4 MB.** Still negligible on disk; supports Q-PA-2 ("ship all, gate at load") comfortably.
- The function index is ~70 bytes per entry → 6,035 entries ≈ ~410 KB index. The §6.2 SKILL.md sketch suggests "~5–15 KB total" for the index, which is **light by ~25×** at full corpus scale. Phase 3.6 may want to either (a) ship a compact index format (binary or JSONL with skill-side parsing), or (b) split the index per-tier so only Tier 1 + active-Tier-2 entries load. The spike's SKILL.md is the naive shape — workable for a few hundred entries, not for thousands.

Doc-coverage observation: ~51% of vanilla/SKSE/3rd-party functions carry *some* documentation (line comment or PEX docstring). The remaining ~49% will render in §6 format with a name, flags, and parameter table but no prose. That's not a regression vs. the user reading raw `.psc` — it's the source-of-truth state — but Phase 3.6 should expect "function exists, no description" to be common, and the eval set per Q3 should exercise this case.

### 11.6 What the spike did NOT validate

- **CK Wiki commentary** (§2.1's `parsoid-service` integration). Pulling MediaWiki content for vanilla + SKSE methods needs the parsoid submodule + Composer + a running parsoid instance. Skipped here intentionally — the bare `.psc` parser produces enough to validate §6 format. Phase 3.6 should plan a separate sub-spike to verify the CK-Wiki ingestion path actually works against current CK Wiki, since this is the part of Option C that gives the biggest content uplift over a from-scratch Option B parser.
- **GitHub-wiki commentary** for `po3` and `skyui-sdk`. Same shape as CK Wiki — needs the upstream `prepare:wiki-repo:*` scripts to clone the wikis, then the indexing layer to integrate. Not exercised.
- **Inheritance aggregation.** §3.2's "What methods does Actor actually have, including inherited from ObjectReference and Form" feature lives in the `indexing/` layer (`tsx ./src/papyrus/indexing/index-all.ts`), NOT in `parsing/`. The spike's `Actor.md` shows Actor's *own-declared* methods only; methods inherited from ObjectReference/Form are not folded in. The §6.3 "section headers for grouping" is fine; aggregating-up inherited methods is a separate transform pass Phase 3.6 must add (input is the same JSON; the indexing layer or an analogous Housecarl-side pass walks the `extends` chain).
- **Cross-source resolution / disambiguation.** PushString lives in both `papyrusutil/PapyrusUtil` and `papyrusutil/StorageUtil`-class shapes, and similar collisions across sources. The spike's SKILL.md index uses unqualified function names; multiple sources defining the same name produce non-unique entries. §6.2's "Multiple matches → check source qualifier" guidance is correct — Phase 3.6 should make the qualification explicit in the index format itself rather than leaving it to lookup-time disambiguation.
- **Tier 2 modlist scan for runtime gating.** Out of scope for a parser-only spike; depends on the daemon and the `modlist-authoring` skill router (Phase 3.1 + 3.6).
- **Layered WebFetch fallback** (Q-PA-3/Q-PA-4). Out of scope for a parser-only spike.

### 11.7 Implications for Phase 3.6 author

What the Phase 3.6 sub-phase author can take from this spike at hand-off:

1. **Option C remains the right call.** The spike tested only the bare-parser path, which already produces 90% of what we need (signatures, parameters, doc-comments). The CK-Wiki + inheritance-aggregation layers (which Option B would force us to rebuild from scratch) are still implemented upstream and available; this spike just didn't exercise them. The §3 cost/value table holds.
2. **Pin the upstream commit explicitly in the build pipeline.** Q-PA-6 says always-latest, but until the dirent fix lands upstream there's a real "build randomly breaks on a Node version bump" risk. Either upstream the patch and pin a known-good commit until merged, or carry the patch in Housecarl's build script. Either is fine; just don't leave it implicit.
3. **Build-pipeline shape:** clone upstream → `pnpm install --ignore-scripts` → run `ts-json-schema-generator` directly twice → `tsx ./src/papyrus/parsing/parse-or-load-all.ts` → consume `public/raw.json` → run our transform → emit pre-packaged markdown into the installer payload. Same shape regardless of Phase 3 stack choice. Total cold-build time after `pnpm install`: <1 s for the parser + transform. `pnpm install` itself is 30–60 s + cache.
4. **Revise the doc text** in §3.2 ("Node 22+, pnpm, tsx, ~80+ npm deps" → also "+ corepack, plus a way to run pwsh-style scripts or skip them"), §4 step 2 (`--filter parser` → `--ignore-scripts`), §4 step 3 (drop "Verify exact path during Phase 3.6 spike" — verified, it's `public/raw.json`), §7 footprint sketch (Tier 1 ~540 KB; Tier 1+2 ~1.4 MB; index ~410 KB at corpus scale). Author can fold these in when they pick up the design input.
5. **Plan a CK-Wiki + inheritance-aggregation sub-spike early in 3.6.** Those two layers are where Option C earns the most over Option B, and the spike didn't touch either. If they turn out to be brittle, the fall-back to Option B is meaningful, not theoretical. (The §3.3 trigger conditions still apply; this just identifies *which* parts of Option C deserve early validation.)
6. **The §6 format itself doesn't need format changes.** The 3 rendered samples in [dev/papyrus-spike/markdown-samples/](dev/papyrus-spike/markdown-samples/) are concretely workable. Minor refinements Phase 3.6 may want — none load-bearing — include: escape leading `#` characters in `documentationComment` content (Papyrus `;;` comments occasionally render as accidental markdown headings); decide whether to surface `isBetaOnly` / `isDebugOnly` flags in the visible flag string vs. a tagged section; choose a stable convention for instance-method-vs-global qualification in the function index (the spike used `Script#Method` / `Script.Function` — a defensible default but Phase 3.6 should lock the convention explicitly).
