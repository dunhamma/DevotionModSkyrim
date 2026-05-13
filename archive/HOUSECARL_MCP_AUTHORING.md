# HOUSECARL_MCP_AUTHORING — MCP Tool Description Authoring Standard

**Status:** locked 2026-04-30 by Aaron (Phase 1 P1.2).
**Owner:** Phase 1 conductor
**Applies to:** Every `@mcp.tool` registration (or equivalent) in the Housecarl MCP plugin, every JSON-Schema property `description`, and any place where a tool exposes a string that Claude reads at session start.

---

## 0. Why this standard exists

Tool descriptions in `@mcp.tool` registrations and skill `description:` frontmatter ARE the consumer-facing documentation Claude reads at session start. They are not human dev notes. They are not changelog entries. They are the mechanism by which the model decides whether to call a tool, which parameters to pass, and whether to batch.

The Claude_MO2 project shipped from v2.9.2 → v2.9.4 with batched-read parameters whose property descriptions led with internal version markers like `"v2.9.2 batch read mode"` and `"Phase 1 axis 2"`. A real consumer Claude on 2026-04-29 then ran ~3,500 sequential `mo2_record_detail` calls instead of using the `formids` batch parameter — because the operational guidance was buried five lines deep behind dev jargon. v2.9.5 was a reactive single-session ship that rewrote those descriptions action-first and retired the parallel KB layer that had drifted (full retrospective: `<old-repo>/dev/plans/v2.9.5_descriptions_redesign/PLAN.md`).

This standard exists to prevent that entire failure mode at the foundation, before any Housecarl tool is registered. Any tool description that violates a rule below is a foundational pattern problem the moment it lands, not a bug to fix on the next release.

---

## 1. Sources of authority

These are the sources cited by name throughout this document. They are external, current, and hold higher weight than any organic Claude_MO2 pattern that emerged ad-hoc:

- **MCP specification — Tools.** `https://modelcontextprotocol.io/specification/2025-11-25/server/tools.md` (and the concept page `https://modelcontextprotocol.io/docs/concepts/tools`).
- **SEP-986 — Tool name format.** `https://modelcontextprotocol.io/seps/986-specify-format-for-tool-names.md`. Final standards-track.
- **Anthropic — Define tools.** `https://platform.claude.com/docs/en/agents-and-tools/tool-use/define-tools`. The "Best practices for tool definitions" section is canonical.
- **Anthropic Engineering — Writing tools for agents.** `https://www.anthropic.com/engineering/writing-tools-for-agents`. The "describe to a new hire" framing.
- **Claude_MO2 v2.9.5 retrospective.** `<old-repo>/dev/plans/v2.9.5_descriptions_redesign/PLAN.md` and `PHASE_1_HANDOFF.md`. The empirical failure case this standard is built to prevent.
- **Post-v2.9.5 corrected descriptions.** `<old-repo>/mo2_mcp/tools_records.py:335-462` (the `mo2_record_detail` rewrite) and `:501-535` (the `mo2_plugin_conflicts` warning). These are the in-house worked examples.

`<old-repo>` = `C:\Users\compl\Documents\Stuff for Calude\Claude_MO2_project\Claude_MO2\` for the duration of the rebuild.

### 1.1 Operational directive — invoke Anthropic skills at authoring time

Two Anthropic skills carry upstream authority over the surfaces this standard governs. They have non-overlapping scopes; both are invoked at the relevant times.

- **`mcp-builder`** (<https://github.com/anthropics/skills/tree/main/skills/mcp-builder>) — guide for creating new MCP servers end-to-end: deep research/planning, implementation (Python FastMCP or Node/TypeScript MCP SDK), review/testing, evaluation. Authoritative for Phase 3 scaffolding of `housecarl_mcp/` and any future MCP-server project. **Not bundled with Claude Code by default**; install via `/install anthropics/skills/mcp-builder` (or the equivalent plugin-marketplace path) before scaffolding begins.
- **`anthropic-skills:skill-creator`** — Anthropic's description-engineering procedural body: description-optimization loop, eval-set construction, authoring conventions. Authoritative for ongoing tool and property description authoring — the primary scope of *this* standard. Per § 7.1, the MCP-tool and skill description surfaces share their load-bearing rules (action-first lead, no version markers, no internal jargon, no decorative content), so skill-creator's description guidance applies on the MCP side as well.

**Operational rule.** Before authoring, editing, or auditing any tool or property description, invoke `anthropic-skills:skill-creator` via the Skill tool at the start of the session. Before scaffolding a new MCP server (Phase 3 `housecarl_mcp/` creation, or any future MCP-server project), additionally invoke `mcp-builder` via the Skill tool — assuming it has been installed. Both invocations put the upstream Anthropic guidance in context alongside this Housecarl-scoped overlay and reduce drift between this standard's quoted snippets (lock-time snapshot) and the live skills (current). Skip only when Aaron has authorized the specific edit.

**Dev-team-side vs user-side authoring (post-Q5).** When this standard governs *user-side* authoring (post-v1.0 install), the Q5 meta-skill cluster (`skill-authoring` specialist) is the user-facing entry point and itself invokes `skill-creator` with Housecarl-standards context bundled in `references/`. The §1.1 operational rule above applies to dev-team authoring inside the Housecarl repo, where direct `skill-creator` invocation is correct.

### 1.2 Verifying Anthropic-skill claims

The bundled-skills surface (the available-skills list shown at session start) is not exhaustive — many Anthropic-published skills ship via the public repo at <https://github.com/anthropics/skills> and install on-demand via `/install anthropics/skills/<skill-name>`. `mcp-builder` itself is the precedent: published but not bundled by default; missing it caused a misstatement in this standard's first §1.1 draft (2026-04-30) that had to be revised after Aaron flagged the omission. Before concluding that no relevant Anthropic-published skill exists for a description- or MCP-authoring concern, web-search or fetch the repo's skill index. Don't infer absence from the bundled list alone.

---

## 2. Tool-level description format

### Rule 2.1 — Action-first lead. The first sentence MUST be a single declarative action that names what the tool does in user-visible terms.

The opening clause is what Claude sees in the tools listing when scanning the registry. It must be parseable in isolation.

The action lead MUST:
- Begin with an imperative verb or a verbed noun phrase ("Get…", "Read…", "Resolve…", "Create…", "List…", "Show…", "Search…").
- Name the tool's user-visible output (FormID lookups, file contents, patch plugin, conflict chain, etc.).
- Fit on one line at typical terminal width (≤ ~120 chars).
- Be self-contained — no pronoun reference to surrounding context, no dependency on a prior sentence.

The action lead MUST NOT:
- Begin with version markers ("v2.9.2…", "Phase 1…").
- Begin with internal architecture jargon ("Bridge subprocess for…", "Mutagen-backed…").
- Begin with parameter-name descriptions ("Given a FormID,…").
- Begin with caveats or warnings ("Warning:…").

**Conforms (post-v2.9.5, `<old-repo>/mo2_mcp/tools_records.py:338`):**
```python
description="Get full interpreted field data for one or more records. ..."
```

**Conforms (post-v2.9.5, `<old-repo>/mo2_mcp/tools_records.py:469`):**
```python
description="Show every plugin that modifies a record, in load order. ..."
```

**Does NOT conform (pre-v2.9.5, the failure case):**
```python
description="v2.9.2 Phase 1 axis 2 batch read mode. ..."
```

**Does NOT conform (caveat-first):**
```python
description="Warning: do NOT call this on heavy plugins. Show plugin overrides..."
```
The warning is real and valuable — but it goes in sentence 2 or later, not sentence 1. See Rule 2.4.

### Rule 2.2 — Detail floor: at least 3-4 sentences for any non-trivial tool.

Anthropic's published guidance is unambiguous: *"Provide extremely detailed descriptions. This is by far the most important factor in tool performance. […] Aim for at least 3-4 sentences per tool description, more if the tool is complex"* (`https://platform.claude.com/docs/en/agents-and-tools/tool-use/define-tools`, "Best practices for tool definitions").

A Housecarl tool description MUST contain enough sentences to cover:
- **What it does** (Rule 2.1's action lead).
- **When to use it** (the trigger condition that distinguishes it from sibling tools).
- **Key parameters or modes** (any parameter whose absence would cause the wrong call shape — batch vs single, projection, expansion).
- **Important caveats** (output-size warnings, ordering guarantees, what's NOT returned).

Trivial tools (single-arg pure lookups with no caveats and no siblings) MAY be shorter; the floor is 1 well-formed sentence with the action-first lead. Use this exception sparingly — most tools have at least one caveat worth surfacing.

**Conforms (4-sentence minimum, `mo2_resolve_path` style — `<old-repo>/mo2_mcp/tools_filesystem.py:18-21`):**
```python
description=(
    "Resolve a game-relative path through MO2's virtual file system "
    "to its real location on disk. Shows which mod provides the file "
    "and which other mods also contain it (conflict losers)."
)
```
This passes — three sentences, action-first, names what it does, what it returns, what extra info accompanies the answer. Acceptable for a simple resolver.

**Does NOT conform (Anthropic's stated anti-pattern, `https://platform.claude.com/docs/en/agents-and-tools/tool-use/define-tools`):**
```python
description="Gets the stock price for a ticker."
```

### Rule 2.3 — Batching/efficiency guidance is bolded and immediately follows the action lead, when applicable.

If a tool has a batch-mode parameter, a perf-relevant cardinality threshold, or a known cheap-vs-expensive call shape, the batching guidance MUST appear in sentence 2 (or the second prominent position) and MUST be bolded with markdown asterisks.

Threshold: any tool whose per-call latency is ≥ ~100ms or whose payload grows non-trivially with N MUST surface a batching/cardinality hint. Tools where per-call cost is ≤10ms and payload is bounded by a small constant MAY omit this.

The bolded position uses Markdown emphasis (`**...**`) inside the JSON string — Claude reads markdown in tool descriptions. Bolding is reserved for:
- Batch hints ("**For reading more than ~2 records, prefer the formids batch parameter…**").
- Hard warnings about output size or context saturation ("**Warning: do NOT call this on plugins that touch CELL or WRLD…**").
- **Side-effect classification** — for tools whose read-only / write / destructive class is not obvious from the action lead, surface it explicitly as a bolded prefix in sentence 1 or 2: `"**Read-only.** Resolve a game-relative path..."` or `"**Write — produces patch ESP.** Apply override to record..."` or `"**Destructive — overwrites mod files in place.** ..."`. Added 2026-05-02 per Q11 lock + STALENESS_AUDIT_REPORT.md MCP_AUTHORING F3. Q11 read-only investigation flows (`crash-diagnostics`, `mod-dissection`) compose queries on demand against any tool whose read-only-ness is statable; surfacing the classification at-a-glance lets the investigation flow filter candidate tools without loading full descriptions.

Bolding is NOT used for general emphasis, type names, or aesthetic decoration. Two or three bolded clauses per tool, max (one batch/perf, one warning, one side-effect classification — overlap allowed where natural, e.g., a destructive tool's warning subsumes its classification).

**Conforms (`<old-repo>/mo2_mcp/tools_records.py:338-344`):**
```python
description=(
    "Get full interpreted field data for one or more records. "
    "Provide a FormID ('Skyrim.esm:012E49') or Editor ID. "
    "**For reading more than ~2 records, prefer the formids batch "
    "parameter over multiple parallel calls — each individual call "
    "pays a ~900ms subprocess startup; one batched call pays it "
    "once.** Returns all fields with named values, enum labels, "
    "and flag names. ..."
)
```

**Does NOT conform (batch hint exists but buried 5 lines deep — the v2.9.5 failure case):**
```python
description=(
    "v2.9.2 Phase 1 axis 2 batch read mode for record details. "
    "Get full interpreted field data for one or more records. "
    "Subprocess-backed via mutagen-bridge. "
    "Pass formid for single, formids for batch. "
    "Use formids when reading more than ~2 records to amortize startup. "  # <- buried lead
    "..."
)
```

### Rule 2.4 — Sentence ordering: action → trigger → batch/perf → mode/parameter summary → caveat.

The narrative arc inside the description follows the order in which Claude needs the information to make a correct call.

Recommended skeleton:

```
Sentence 1:  ACTION         — what the tool does (Rule 2.1).
Sentence 2:  INPUT SHAPE    — what the user provides (FormID, plugin name, query).
Sentence 3:  BATCH/PERF     — bolded batching or efficiency hint, if applicable (Rule 2.3).
Sentence 4+: MODE SUMMARY   — concise tour of secondary parameters (projection,
                              expansion, cross-product, mutually exclusive options).
Last:        CAVEAT/WARNING — output-size warnings, "this does NOT return X",
                              "use sibling tool Y for case Z" (Rule 2.6).
```

Skip a slot when not applicable. Never reorder so the caveat or version marker leads.

**Conforms (`<old-repo>/mo2_mcp/tools_records.py:338-354` — `mo2_record_detail`):** action → input shape → bolded batch hint → returns shape → mode tour → cross-tool sibling note.

**Conforms (`<old-repo>/mo2_mcp/tools_records.py:506-515` — `mo2_plugin_conflicts`):** action → returns shape → bolded warning → default behavior → flag-toggle. The bolded warning lives in sentence 3 because the action and returns matter first.

### Rule 2.5 — Performance numbers are concrete, sourced, and survive a release.

When perf numbers appear in a description (latencies, payload-cut percentages, batch-amortization figures), they MUST:
- Use approximate notation ("~900ms", "~80%", "~5x speedup") so a 10% drift in actual measurement does not falsify the description.
- Be tied to a representative scenario in the same sentence ("on a 3-spell race record", "at N=200", "on a typical RACE/NPC record").
- Be traceable to either a coverage-smoke cell or a plan-archive measurement (cite mentally; the cell or archive is the auditable source).

Perf numbers MUST NOT:
- Cite an exact integer that will silently rot ("932.7ms" — drifts; use "~900ms").
- Reference a phase or version internally ("v2.9.2 measured", "Phase 1 axis 6 reading").
- Be placed in tool-level descriptions when they belong on a specific parameter (see §3).

**Conforms (perf number with scenario, in property description, `<old-repo>/mo2_mcp/tools_records.py:386-397`):**
```python
"description": (
    "Read multiple records in a single batched call. Use this "
    "any time you need more than ~2 records — one batched call "
    "amortizes the ~900ms subprocess startup across the batch "
    "(per-record marginal drops to ~19ms at N=200). ..."
)
```

**Does NOT conform (over-specific number tied to an internal phase, post-rot risk):**
```python
"description": "v2.9.2 Phase 1 axis 6: 932.7ms p50 startup, 19.4ms marginal."
```

### Rule 2.6 — Cross-tool sibling references are explicit when a tool would otherwise be misused.

If there is a sibling tool that should be used in a specific case the current tool doesn't cover well, the description MUST name the sibling explicitly. This prevents the "I'll just keep calling this one" failure mode that produced 3,500 sequential calls in v2.9.5's trigger event.

The reference uses the sibling's full registered name ("`mo2_query_records`", not "the query tool") so a Claude scanning the registry can resolve it directly to a tools/list entry.

**Conforms (`<old-repo>/mo2_mcp/tools_records.py:511`):**
```python
"... For those, use mo2_query_records filtered to the plugin instead."
```

**Does NOT conform:**
```python
"... For large plugins, use the other tool instead."
```

---

## 3. Parameter (property) description format

Every property in a tool's `input_schema` MUST carry a non-empty `description`. The MCP spec's `tools/list` response surfaces these in the same payload Claude reads as the tool itself; they are first-class consumer documentation, not internal annotation.

### Rule 3.1 — Property description leads with purpose, not type.

The first clause of a property description MUST state what the parameter is FOR (the consumer's purpose), not its type or representation.

The type lives in the JSON Schema's `"type"` field already. Repeating it in the description is wasted tokens and pushes the purpose deeper.

**Conforms (`<old-repo>/mo2_mcp/tools_records.py:386-397`):**
```python
"formids": {
    "type": "array",
    "items": {"type": "string"},
    "description": (
        "Read multiple records in a single batched call. Use this "
        "any time you need more than ~2 records — ..."
    ),
}
```
Lead clause states the purpose ("Read multiple records in a single batched call") and the trigger ("Use this any time you need more than ~2 records"). The fact that it's an `array` of `string` is in the schema fields above.

**Does NOT conform:**
```python
"formids": {
    "type": "array",
    "items": {"type": "string"},
    "description": "Array of FormID strings. v2.9.2 batch read mode."
}
```
Lead clause repeats the type and tags the version. The consumer's purpose ("when do I use this?") is missing entirely.

### Rule 3.2 — When-to-use clause is mandatory for any parameter whose presence vs absence changes call shape or perf.

If passing the parameter switches the tool into a different mode (single vs batch, full vs projected, plain vs expanded) — or materially shifts performance — the description MUST include an explicit "Use this when…" or "Use this any time…" clause.

This is the rule that directly prevents the v2.9.5 failure: the `formids` parameter's presence vs absence changed `mo2_record_detail` from N×900ms-startup to 1×900ms+amortized, and the original description didn't surface the trigger condition operationally.

**Conforms (`<old-repo>/mo2_mcp/tools_records.py:402-414` — `fields` projection):**
```python
"description": (
    "Project the response to only the requested field paths. "
    "Use this when you only need specific fields from a large "
    "record — cuts payload ~80%% on a 3-5 path subset of a "
    "typical RACE/NPC_/etc record. ..."
)
```

**Conforms (`<old-repo>/mo2_mcp/tools_records.py:419-434` — `expand_links`):**
```python
"description": (
    "Inline the detail of FormLinks at named paths. Use this "
    "when you'd otherwise chase a FormLink with a second "
    "mo2_record_detail call — eliminates that round-trip "
    "(~5x speedup on a 3-spell race record; scales with "
    "link-count). ..."
)
```

**Does NOT conform:**
```python
"description": "Optional field projection list. See tool description."
```
No when-to-use clause. "See tool description" is an explicit pointer to the parallel-document anti-pattern (§5).

### Rule 3.3 — Perf data lives on the parameter when the parameter controls the perf.

A perf number that quantifies the parameter's effect (payload reduction, latency drop, scaling shape) MUST be on the parameter's description, not in the tool-level description. The tool-level description carries the high-level batch hint (Rule 2.3); the parameter description carries the calibrated number.

**Conforms (split between tool and param):**
- Tool: `"**For reading more than ~2 records, prefer the formids batch parameter — each individual call pays a ~900ms subprocess startup; one batched call pays it once.**"`
- Param `formids`: `"... amortizes the ~900ms subprocess startup across the batch (per-record marginal drops to ~19ms at N=200)."`

The tool surfaces the qualitative break-even ("more than ~2 records"). The parameter surfaces the quantitative scaling ("~19ms at N=200"). Each lives where Claude needs it.

**Does NOT conform (everything on the tool):**
- Tool: `"... ~900ms startup, ~19ms marginal at N=200, scaling to ~70x at N=200..."`
- Param `formids`: `"Array of FormID strings."`

The number landed on the tool description but the param is bare. Claude scanning the param schema sees nothing actionable.

### Rule 3.4 — Mutual exclusion, output-shape change, and required combinations are stated on the parameter, both directions.

When a parameter is mutually exclusive with another, or its presence changes the response shape, or it's required when a sibling parameter is set, the description MUST state both directions. State it on EACH side of the relationship — Claude may read either parameter's description first depending on the call it's planning.

**Conforms (`<old-repo>/mo2_mcp/tools_records.py:368-381` — `plugin_name` ↔ `plugin_names`):**
```python
"plugin_name": {
    "description": "... Mutually exclusive with plugin_names.",
},
"plugin_names": {
    "description": (
        "Fetch the record from each listed plugin in one batched "
        "call. Output shape becomes {'records': [...]} instead of "
        "a single record. Mutually exclusive with plugin_name. ..."
    ),
}
```
Both sides cite the exclusion. `plugin_names` additionally states the output-shape shift, which `plugin_name`'s description doesn't need (`plugin_name` produces the default shape).

**Does NOT conform (one-sided):**
```python
"plugin_name": {"description": "Plugin to read from."},
"plugin_names": {"description": "Multi-plugin read. Mutually exclusive with plugin_name."},
```
A consumer Claude planning a `plugin_name` call sees no warning that `plugin_names` exists or that it could be combined.

### Rule 3.5 — Defaults are explicit and surfaced in the description AND the schema.

Where a parameter has a meaningful default (especially a default that affects behavior — `include_disabled=false`, `limit=50`, `recursive=false`), the default MUST be:
- Stated in the property's `description` text, in parentheses or as a trailing clause ("Default 50.", "(default false, enabled-only)").
- Set as the schema's `"default"` field for tooling and validation consumers.

The description-side statement matters because Claude reads the description as prose; the schema-side `default` matters because some validators surface it separately. Both populated, no drift between them.

**Conforms (`<old-repo>/mo2_mcp/tools_records.py:449-457`):**
```python
"include_disabled": {
    "type": "boolean",
    "description": (
        "Resolve against disabled plugins too. Default false "
        "(enabled-only). Required when reading a specific "
        "disabled plugin's version of a record, or when the "
        "record only exists in disabled plugins."
    ),
    "default": False,
}
```

**Does NOT conform (description and schema disagree):**
```python
"include_disabled": {
    "type": "boolean",
    "description": "Include disabled plugins. Default true.",
    "default": False,
}
```
Drift. The description says one thing, the schema says another — a Claude reading the description plans a different call than a strict validator will accept.

### Rule 3.6 — Format, examples, and sentinel values appear in the description for non-obvious encodings.

Wherever the parameter has an encoding the consumer can't infer from the type ("FormID looks like Plugin:LocalID"), the description MUST give a concrete example.

Encodings that count as non-obvious: composite IDs (FormIDs, semver-with-build, hash:branch refs), domain-specific glob patterns, project-specific path conventions, dotted property paths into a Mutagen-shaped record tree.

Encodings that DON'T need an example (already obvious from the parameter name and type): `limit: int`, `enabled: bool`, plain English-language `name: string` for a free-text identifier.

**Conforms (`<old-repo>/mo2_mcp/tools_records.py:307-308`):**
```python
"formid": {
    "type": "string",
    "description": "Exact FormID lookup: 'PluginName:LocalID' (e.g. 'Skyrim.esm:012E49')",
}
```

**Conforms (glob pattern, `<old-repo>/mo2_mcp/tools_filesystem.py:57-58`):**
```python
"pattern": {
    "type": "string",
    "description": "Glob filter, e.g. '*.esp' or '*.nif'",
}
```

**Does NOT conform (encoding present, example missing):**
```python
"formid": {"type": "string", "description": "FormID of the record"}
```

### Rule 3.7 — Required vs optional is in the schema, not the description.

The `"required"` array at the schema level is the single source of truth for what's required. Description text MUST NOT duplicate this with phrases like "(required)" or "(optional)". Drift between the two is silent and dangerous; consumers may trust either.

**Conforms:**
```python
"input_schema": {
    "type": "object",
    "properties": {
        "plugin_name": {
            "type": "string",
            "description": "Plugin filename (e.g. 'Dawnguard.esm')",
        },
    },
    "required": ["plugin_name"],
}
```

**Does NOT conform:**
```python
"plugin_name": {
    "type": "string",
    "description": "Plugin filename (REQUIRED). Format: 'Dawnguard.esm'.",
}
```

---

## 4. What NOT to put in descriptions — explicit blacklist

The blacklist below is binding. Every item maps to either (a) the v2.9.5 failure pattern that triggered this rebuild, or (b) Anthropic-published anti-patterns. A description containing any of these items at registration time is a Phase-2-audit BLOCK regardless of what the rest of the description does correctly.

### Rule 4.1 — No version markers ANYWHERE in tool or property descriptions.

Examples of forbidden version markers (verbatim from the v2.9.5 failure):
- `"v2.9.2 batch read mode."`
- `"v2.9.2 Phase 1 axis 2."`
- `"v2.9.0:"` as a clause prefix.
- `"Phase 1 axis 6"`, `"Phase 1 perf probe"`.
- `"As of v2.7.1, ..."` — the implementation history doesn't matter to a consumer.
- `"NEW in v3.0:"`, `"DEPRECATED in v2.9.x:"` — see §6 for the correct deprecation handling.

Versions live in the CHANGELOG and the plan archive (per `HOUSECARL_RELEASE_CADENCE.md` once that lands). They do not live in the consumer-facing tool registry.

**Quick test:** grep the description for `r"v\d+\.\d+"` and `r"[Pp]hase \d+"`. Either match is a violation.

### Rule 4.2 — No phase/axis/probe/sprint/internal-process tags.

Forbidden tags (verbatim or close paraphrase from the failure case):
- `"Phase 1 axis 2"`, `"axis 6"`, `"axis 5/6"`.
- `"Phase 1 perf probe"`, `"P1 perf probe"`.
- `"Sprint X"`, `"Milestone Y"`.
- `"WIP"`, `"draft"`, `"experimental"` — if it ships, it's not WIP. If it shouldn't ship, it shouldn't be in the registry.
- `"P0 baseline"`, `"P0 measurement"`.

These tags identified internal dev process boundaries that are invisible to and useless to a consumer. If a tool has a stability concern that consumers should know about (e.g., "schema may change"), state the concern in plain language ("This tool's response shape is provisional and may change in the next minor release") rather than tagging the dev phase.

### Rule 4.3 — No bridge/transport/internal-architecture jargon as the lead.

Forbidden lead phrases:
- `"Calls mutagen-bridge.exe via subprocess..."` — implementation detail.
- `"Bridge-backed tool for..."` — same.
- `"Daemon round-trip required..."` — same (and Housecarl will not preface every tool with "daemon" given that's the substrate; consumers don't care).
- `"Roslyn-evaluated..."` — implementation detail.
- `"NDJSON-framed..."` — implementation detail.

Consumers care about what the tool does (the `mo2_record_detail` action lead) and about user-visible characteristics (what's enabled by default, what's mutually exclusive). Internal architecture lives in repo docs, not the tool registry.

If a real implementation note matters operationally — e.g., a startup cost the consumer sees as latency — surface it as the consumer-visible effect, not the internal cause. Say `"Each call pays a ~900ms cold-start cost"`, not `"Each call spawns a Mutagen-bridge subprocess that performs a cold-load of the LinkCache"`.

### Rule 4.4 — No low-level technical identifiers as parameter names or in descriptions where a domain-meaningful name exists.

Per Anthropic Engineering: *"input parameters should be unambiguously named: instead of a parameter named `user`, try a parameter named `user_id`. […] eschew low-level technical identifiers (for example: `uuid`, `256px_image_url`, `mime_type`)"* (`https://www.anthropic.com/engineering/writing-tools-for-agents`).

For Housecarl specifically:
- `formid` (domain-meaningful) NOT `id` or `uuid`.
- `plugin_name` (domain-meaningful) NOT `plugin` or `target`.
- `editor_id` (domain-meaningful) NOT `name` or `key`.

When in doubt, the parameter name should be specific enough that a consumer Claude could explain in one sentence what it identifies, without referring to the tool's description.

### Rule 4.5 — No "see X.md" or "refer to KB_Y for details" references.

Forbidden:
- `"See kb/KB_Tools.md for the full reference."`
- `"Refer to CONDITIONS_AUDIT.md for slot signatures."` (this one was tolerated in `tools_patching.py` for an extreme case — Housecarl tightens.)
- `"Documentation in dev/plans/v2.9.X_*.md."`
- `"See the bridge's PatchEngine.cs for behavior."`

The tool description IS the documentation (§5). Pointers to a parallel layer drift the moment either side changes; the v2.9.5 retrospective documents that drift directly. If the information matters, inline it in the description. If the information is too long to inline, the tool is doing too much — split it (per Rule 2.7 below) or surface the sub-shape in a separate tool with its own description.

The single allowed exception: a **schema-grade reference** to a Mutagen public type or a published external standard (e.g., "see Mutagen.Bethesda.Skyrim's `APerkEffect` for the leaf class set") — and only when that reference is a genuine external API surface that consumers may want to look up, not a ride-along internal note.

### Rule 4.6 — No emojis, no decorative Unicode, no ASCII art.

Tool descriptions are tokens. Decorative characters are wasted tokens that don't help the consumer choose a tool. Bolded markdown (`**...**`) is allowed for emphasis per Rule 2.3; that's the limit.

Forbidden: `"⚡ Fast batch read mode"`, `"🚀 Use this when..."`, `"=== PATCHING ==="`.

This rule applies equally to skill descriptions per `HOUSECARL_SKILL_AUTHORING.md` (cross-link: shared rule with P1.1 — see §7).

### Rule 4.7 — No author signatures, no attribution lines, no "credits" tags.

Forbidden: `"By Aaronavich"`, `"Built by..."`, `"(c) 2026 ..."`.

Authorship belongs in `LICENSE`, in the repo's top-level `README.md`, and in the package's metadata (e.g., `pyproject.toml` `authors` field). A tool description is not a copyright notice.

### Rule 4.8 (corollary of 2.7) — Don't pack three tools into one description.

If a description has to enumerate disjoint behaviors with phrases like "Also supports…" or "Can additionally…" pointing at semantically-distinct operations, the tool is two or more tools. Split it.

This isn't a description-authoring problem per se — it's a tool-design problem that surfaces in the description. The fix is structural, not editorial.

**Heuristic for splitting:** if the action lead can't truthfully describe everything the tool does without a comma joining two verbs ("Get records and modify them"), split. The Anthropic guidance ("consolidate related operations") is real, but the consolidation is about one logical operation with parameter-driven mode selection (the `op: "override" | "merge_leveled_list"` discriminator on `mo2_create_patch`), not about packing semantically-distinct operations.

---

## 5. Schema-as-documentation principle

### Rule 5.1 — The MCP tool registry is the single source of truth for what tools exist, what they do, and how to call them.

There MUST NOT be a `kb/KB_Tools.md`-equivalent living anywhere in Housecarl. The retired file at `<old-repo>/kb/KB_Tools.md` (deleted in v2.9.5) was a hand-curated parallel reference that drifted: the `formids` batch parameter shipped in v2.9.2, never made it into KB_Tools.md, and contributed materially to the consumer Claude's failure to discover the batch capability.

The registry is the authoritative source because:
- Claude reads it at session start as part of `tools/list`.
- It cannot drift from itself — the description is registered alongside the schema in the same `@mcp.tool` call.
- Consumers (Claude Code, other MCP clients) all see the same content.

A parallel document is at best a redundant copy; at worst (the v2.9.5 case), it drifts and misleads.

**Q6 install-bundle delivery (2026-05-01).** Per Q6 lock, Housecarl's MCP plugin is auto-discovered via `<housecarl-install>/.mcp.json` when Claude Code is rooted at the housecarl folder (`<MO2-instance>/Plugins/housecarl/`). The `tools/list` response from the single `housecarl_mcp` server is the registry; sibling references (Rule 2.6) resolve within that single server. No separate skill-serving runtime is needed — bundled-with-install is the AD-3 surface.

### Rule 5.2 — Permitted documents under `kb/` (or equivalent) are narrow, standalone, and never duplicate registry content.

`HOUSECARL_DOC_HYGIENE.md` (P1.3) will set the binding rules for what documents exist. From the MCP-authoring side, the rule is: any kb-class document is forbidden from re-stating tool descriptions, parameter shapes, or "available tools" lists. A kb-class document MAY:
- Cover a domain topic the tool surface doesn't naturally describe (e.g., "How Bethesda's leveled-list resolution works", "Why ESL flags are sticky").
- Provide a worked example or tutorial that uses the tool surface but doesn't redefine it.

A kb-class document MAY NOT:
- Enumerate "the available MCP tools" with descriptions.
- Repeat or paraphrase a tool's parameter list.
- Document call patterns by name (those go in the relevant skill body or in the tool's own description).

### Rule 5.3 — Cross-linking from tools to other tools is by registered name; cross-linking from tools to documents is forbidden.

Tools may reference siblings by full registered name (Rule 2.6). Tools may not reference external documents (Rule 4.5). The asymmetry is intentional: name-references resolve at the consumer-side via `tools/list` and never drift, while document-references go stale or break.

### Rule 5.4 — The schema is also the validation surface; description-side claims about types, defaults, enums, and required-ness MUST match the schema.

If the description says "(default false)", the schema's `default` field MUST be `false`. If the description says "must be one of `'override'` or `'merge_leveled_list'`", the schema's `enum` field MUST list exactly those values. Drift between description prose and schema fields is a silent contract violation — strict-mode consumers see one truth and prose-reading consumers see another.

Enforcement: a Phase-3 description-linter SHOULD parse description text for parenthesized defaults (`r"\(default ([^\)]+)\)"`), `enum`-style enumerations, and "(required)" tokens, and assert match against the schema. The linter is out of scope for P1.2 to design, but the rule it will enforce is binding from day one.

---

## 6. Versioning and deprecation handling

### Rule 6.1 — Tool descriptions never narrate version history.

A Housecarl-shipped tool description describes the tool as it currently is. It does not narrate "in v0.3.0 we changed X" or "as of v1.2 the default is now Y". Version history lives in the CHANGELOG (per `HOUSECARL_RELEASE_CADENCE.md`).

This is the most direct application of Rule 4.1 to the temporal axis: a consumer Claude reading the description on a v1.5 install does not benefit from learning what v1.2 did differently. A consumer reading on a v1.0 install benefits actively from NOT seeing version-narrative tags that suggest the description is older than reality.

### Rule 6.2 — A tool that is changing materially across a release MUST surface the change as current behavior, not as a transition narrative.

If `mo2_record_detail`'s `formids` parameter is being added in Housecarl v0.4 → v0.5, the v0.5 description states: `"Read multiple records in a single batched call. Use this any time you need more than ~2 records..."` — full stop. It does NOT state: `"NEW in v0.5: batch read mode. Use this any time...".`

The `NEW in vX.Y` framing is a CHANGELOG line, surfaced separately. The description is for consumers in the present tense on whatever version they happen to be running.

### Rule 6.3 — A deprecated tool's description states the deprecation in plain language and names the replacement.

When a tool is being phased out across a release window:

- **Phase 1 of removal (description-deprecation):** the tool's description gains a leading clause stating the deprecation and naming the replacement. The description still describes what the tool does because consumers may still hit it. Format:

  ```python
  description=(
      "**DEPRECATED — replaced by mo2_query_records_v2.** Show every "
      "plugin that modifies a record, in load order. ..."
  )
  ```

  The bolded `DEPRECATED` clause is the only legitimate use of `DEPRECATED` in any description. It's unambiguous to a consumer Claude scanning the registry; it names the replacement; and it remains accurate as the tool is sunset.

- **Phase 2 of removal (registry removal):** the tool stops being registered. The MCP spec already supports this via `notifications/tools/list_changed` (`https://modelcontextprotocol.io/specification/2025-11-25/server/tools.md`). Consumers re-fetch and the deprecated tool is gone.

The two phases MUST NOT collapse into a single release unless the tool is being removed before any external consumer was depending on it. Housecarl v1.0 is the first external-facing release; pre-v1.0 we may collapse freely. Post-v1.0, the two-phase pattern is binding.

### Rule 6.4 — A renamed tool keeps the old name registered with a deprecation pointer for at least one minor release.

If `mo2_record_detail` is being renamed to `housecarl_records_get` between v1.x and v2.0, then v1.x ships both names registered, the old name's description bolded-`DEPRECATED — use housecarl_records_get`, the new name's description full and authoritative. v2.0 may drop the old name.

This applies SEP-986's backwards-compatibility guidance (`https://modelcontextprotocol.io/seps/986-specify-format-for-tool-names.md`): *"Existing non-conforming tool names SHOULD be supported as aliases for at least one major version, with a deprecation warning."*

### Rule 6.5 — A parameter-level deprecation is surfaced in the parameter's description, with the same bolded marker.

For example, deprecating `actor_value` in favor of `parameters.ActorValue` (the v2.9 transition that survived as a back-compat sugar in `<old-repo>/mo2_mcp/tools_patching.py`):

```python
"actor_value": {
    "type": "string",
    "description": (
        "**DEPRECATED — use parameters.ActorValue instead.** "
        "Back-compat sugar for parameters: {ActorValue: ...}. "
        "ActorValue enum name (e.g. 'Health'). Used by GetActorValue. "
        "Either this OR parameters.ActorValue may be supplied; "
        "supplying both surfaces an unambiguous-DSL error."
    ),
}
```

The deprecation is at the head of the description — Claude scanning the parameter sees the redirect first. The original behavior is documented in case a consumer is mid-migration.

---

## 7. Cross-references to other Housecarl standards

### 7.1 Shared with P1.1 (HOUSECARL_SKILL_AUTHORING)

The following rules are shared between MCP tool descriptions (this document) and skill descriptions (`HOUSECARL_SKILL_AUTHORING.md`) and apply identically on both surfaces. P1.1 should name them by their numbering here for cross-linkability:

- **Action-first lead** (Rule 2.1): a skill's `description:` frontmatter must lead with what the skill DOES, in user-visible terms, not an internal-process tag. The `session-strategy` skill's pre-v2.9.5 description triggered on a meta-condition Claude can't predict ("sessions involving extensive MCP work"); the post-v2.9.5 fix uses concrete user-recognizable phrasings ("Use this whenever the user mentions modlists, mods, plugins, conflicts...").
- **No version markers / phase tags / dev jargon** (Rules 4.1–4.3): same blacklist applies to skills.
- **No emojis or decorative Unicode** (Rule 4.6): same.
- **Pushy framing for under-triggering** (Rule 2.1 amplified for skills): per Anthropic skill-creator guidance, skills under-trigger more often than they over-trigger; descriptions are deliberately a little pushy ("even if you think you only need a few calls"). MCP tool descriptions do NOT need the pushy framing because Claude is already prompted to consider every tool the registry exposes — under-triggering is not the failure mode at the MCP-tool level.

### 7.2 Affects P1.7 (HOUSECARL_REPO_LAYOUT)

The "no parallel KB layer" principle (Rule 5.1, Rule 5.2) constrains the repo structure: there is no top-level `kb/` directory whose purpose is "tool reference". Whatever P1.7 lands for the repo layout, it MUST NOT include a tool-reference document path. P1.7 should consume this constraint when laying out documentation directories.

### 7.3 Affects P1.8 (HOUSECARL_NAMING)

Tool naming is constrained by:
- **MCP SEP-986** (`https://modelcontextprotocol.io/seps/986-specify-format-for-tool-names.md`): 1–64 chars, case-sensitive, alphanumeric + `_-./`, no spaces.
- **Anthropic regex** (`https://platform.claude.com/docs/en/agents-and-tools/tool-use/define-tools`): `^[a-zA-Z0-9_-]{1,64}$` for client tools sent via the API. Stricter than SEP-986 (no `.` or `/`). **Housecarl's MCP tools MUST conform to the Anthropic regex** since Housecarl tools are delivered to Claude via the same path.
- **Namespacing principle** (Anthropic engineering): tool names should be prefixed by service to delineate boundaries when the surface grows. P1.8 (HOUSECARL_NAMING.md) locks the `housecarl_*` prefix per its §2 prefix regex `^housecarl_[a-z][a-z0-9_]*$`; every tool registered under the Housecarl MCP server MUST use this prefix.
- **Domain-meaningful suffix** (Rule 4.4): the part after the prefix MUST be domain-meaningful. `housecarl_records_get` not `housecarl_get_things`. P1.8 may go further; this rule is the floor.

### 7.4 Consumed by P1.6 (HOUSECARL_TEST_INFRASTRUCTURE)

Description claims about defaults, enum values, mutual exclusion, and required-ness are validation surfaces (Rule 5.4). The description-linter that enforces description-vs-schema match is naturally at home in the test infrastructure. P1.6 should treat description-linting as a coverage-smoke-class check that runs against every registered tool.

---

## 8. Enforcement and review

### 8.1 Phase-2 audit bucketing

Phase 2 audit (closed 2026-04-30; locked per PORT_MANIFEST.md) used this standard's rules as the description-bucketing rubric. Every old Claude_MO2 tool description encountered was bucketed as follows:

- **PORT (description-clean):** description already conforms to all rules above. Likely candidates: post-v2.9.5 `mo2_record_detail`, `mo2_plugin_conflicts`, `mo2_resolve_path`, `mo2_list_files`, `mo2_read_file` (subject to per-description audit; many of these likely PORT but each must be checked against §2-§4).
- **REBUILD (description-violation, capability needed):** capability is on the FOUNDATION.md "ports" list, but the description violates one or more rules. Rewrite at port time. Most pre-v2.9.5 tools likely sit here unless they were touched in v2.9.5.
- **DROP:** the tool itself is on the FOUNDATION.md DROP list (kb/KB_Tools.md references, retired roadmap items).

The audit produces the bucketing; this standard is the rubric.

### 8.2 Phase-3+ description review at registration time

Every new `@mcp.tool` registration in Housecarl MUST pass:

1. **Action-first lead present** (Rule 2.1).
2. **No blacklist matches** (Rules 4.1–4.7) — automated grep checks for `r"v\d+\.\d+"`, `r"[Pp]hase \d+"`, `r"axis \d+"`, emoji, "WIP", "DEPRECATED" without bolded form, "see kb/", etc.
3. **All properties have descriptions** (§3 preamble).
4. **Required parameters use the schema's `required` array, not prose** (Rule 3.7).
5. **Cross-tool references use full registered names** (Rule 2.6).

The pre-commit hook or CI check is out of scope for P1.2 to design but is the recommended enforcement vector. Until that lands, this standard is enforced by reviewer discipline at PR time.

### 8.3 Pre-ship description audit

Every Housecarl release passes a description-audit step before shipping:

- Read the registered tool descriptions via a `tools/list` call against the running plugin.
- Spot-check the action-first lead on each tool.
- Verify any tool flagged as `DEPRECATED` in the CHANGELOG is bolded-deprecated in its description AND names a replacement.
- Verify no tool description contains a version marker for the release being shipped (this catches the "let me note this is v1.5's new behavior" anti-pattern at the latest possible moment).

This audit step is named in `HOUSECARL_RELEASE_CADENCE.md` (P1.5) as a binding pre-ship checklist item.

---

## 9. Summary — the seven non-negotiables

If a reviewer reads only one section, it is this. A description failing any of these seven is non-conformant regardless of what else it gets right:

1. **Action-first lead** — sentence 1 starts with what the tool DOES, in user-visible terms.
2. **3+ sentences** for any non-trivial tool (Anthropic's published floor).
3. **Bolded batching/perf hint** in sentence 2-3 when the tool has a meaningful batch parameter or known cardinality threshold.
4. **No version markers, phase tags, axis tags, sprint tags, or internal-architecture jargon** — anywhere, ever.
5. **Property descriptions lead with purpose, not type**, and include a "Use this when..." clause for any mode-shifting parameter.
6. **No "see X.md" pointers** — the registry is the source of truth.
7. **DEPRECATED is bolded, names the replacement, and survives one minor version** before the tool is removed.

---

## 10. Worked examples (canonical)

The post-v2.9.5 tool descriptions in `<old-repo>/mo2_mcp/tools_records.py` are the canonical worked examples Housecarl inherits as pattern (the code they describe is REBUILD-bucket per Phase 2; the descriptions themselves are PORT-bucket pattern):

- **`mo2_record_detail`** (`<old-repo>/mo2_mcp/tools_records.py:335-462`) — the canonical complex-tool description. Action-first lead, bolded batch hint, parameter tour, mutual exclusion, output-shape-shift docs, perf numbers split between tool and parameter levels.
- **`mo2_plugin_conflicts`** (`<old-repo>/mo2_mcp/tools_records.py:503-535`) — canonical "tool with a hard caveat". Action lead followed by bolded warning followed by sibling-tool reference.
- **`mo2_resolve_path`** (`<old-repo>/mo2_mcp/tools_filesystem.py:15-36`) — canonical simple-tool description. Three-sentence floor, no batch hint needed, type-safe parameter description with a concrete example.

Housecarl's Phase 3 scaffolding SHOULD reference these worked examples in its own contributing docs once the repo exists. Until then, they live at the paths above.

---

### 10.1 v1.0 tool-category forward-references (placeholder)

Two v1.0 tool categories are locked into ship scope but lack worked examples here because their concrete shape is research-pending. When the underlying research closes, this section becomes the natural home for new worked examples + any category-specific authoring rules.

**File-level VFS tool surface (`housecarl_vfs_*`)** — locked into v1.0 per Q7 amendment 2026-05-01 (vision-alignment); specific tool shape pending Phase 2.7 V2.5 design lock (VFS_RESEARCH_PLAN.md). When V2.5 closes, revisit this standard for `housecarl_vfs_*` worked examples + any category-specific authoring rules (e.g., USVFS-coexistence semantics surfaced in tool descriptions, file-level conflict-resolution result shapes).

**BSA-support tool surface (`housecarl_bsa_*`)** — locked into v1.0 per Q9 amendment 2026-05-01 (capability scope); specific tool shape pending Phase 3.6 dev/research mechanism decision per Q9.1 amendment 2026-05-02 (BSArch CLI wrapper vs from-scratch native). The two mechanisms imply different authoring concerns:
- If BSArch CLI wrapper wins, a new section (provisionally §11 "CLI-wrapper tool authoring") would cover: tool-level descriptions naming the wrapped CLI + subprocess-cost shape; output paths and disk-side effects per Rule 2.4's caveat slot; subprocess error modes (exit code, stderr capture, BSArch-specific failure classes) surfaced as named failure classes consumers can branch on.
- If from-scratch native wins, the native tool authoring slots into existing §2–§5 patterns without category-specific rules.

Defer this standard's BSA-category authoring guidance until Phase 3.6 mechanism lock.

---

**End of standard.** Phase 1 conductor: lock when reviewed.
