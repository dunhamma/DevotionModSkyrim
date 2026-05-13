# HOUSECARL_AGENT_PROTOCOL — Conductor / Executor Pattern

**Phase 1 standard — P1.4.** Status: locked 2026-04-30 by Aaron.

This document codifies the conductor/executor agent pattern for Housecarl. It applies to any multi-item research run, multi-phase ship, or coordinated work where one Claude session orchestrates other Claude sessions via the Agent tool.

The pattern emerged organically across Claude_MO2's v2.9.x release line and was refined in the daemon-architecture research run (2026-04-29). This standard captures the working version so future conductors apply it by reference rather than rediscovering it. **A conductor opening Housecarl for the first time should be able to spawn correct executors after reading only this file plus the per-item plan it's executing.**

---

## 1. When to apply the pattern (and when NOT to)

The conductor/executor pattern has costs (token burn, coordination overhead, context-loss across the conductor/executor boundary, return-summary discipline). Apply it when those costs are recouped; skip it otherwise.

### Apply

- **Multi-item research runs.** Each item is independently scoped, can be done in parallel, and produces a written output that the conductor synthesizes. Reference instance: daemon-architecture research at `<old-workspace>/research/PLAN.md` — 11 items, 5-wide parallelism, single-session completion.
- **Multi-phase shipping work.** Phases run sequentially, each phase's executor produces a handoff doc, the conductor reviews and produces the next phase's kickoff. Reference instance: Claude_MO2 v2.9.X plan archives at `<old-repo>/dev/plans/v2.9.X_*/`.
- **Standards research.** Phase 1 itself uses this pattern — see `<housecarl>/PHASE_1_PLAN.md`.
- **Anything where the working context would otherwise blow past comfortable budget.** Executors keep search results, source-code reads, and exploratory tool calls out of the conductor's window.

### Do NOT apply

- **Single-session description-and-docs ships.** Reference instance: Claude_MO2 v2.9.5, which deliberately broke the multi-phase pattern. PHASE_1_HANDOFF.md (single doc, single session) was the right shape.
- **Small fixes, hotfixes, single-bug investigations.** One Claude session, no orchestration.
- **Anything where the conductor would re-explain context faster than spawning helps.** If the executor prompt would itself run >2,000 tokens of setup context, the work is probably small enough to do in-session — or the plan doc is missing and should be written first.
- **Work that requires interactive user input mid-task.** Executors are batch-shaped: prompt → work → return summary. They don't escalate cleanly to the user mid-flight.

The discriminating question: **does this work produce >1 written output that the conductor will synthesize, AND would each output benefit from a fresh context window?** If yes, use the pattern. If no, don't.

---

## 2. Master Conductor — role definition

The conductor is an **orchestrator**, not an investigator. It holds the plan, spawns executors, reads return summaries and output files, updates state tracking, and writes the cross-item synthesis.

### Conductor responsibilities

1. **Read the plan once at session start.** Plan is authoritative; conductor decisions don't override the plan without an explicit conductor decision.
2. **Spawn one executor per item via the Agent tool.** Each Agent call covers exactly one plan item. No combining items.
3. **Verify model identity** on each return — see § 5.
4. **Read each executor's output file** (not just the return summary). The summary is for routing; the file is the deliverable.
5. **Update PROGRESS.md** after each item completes — see § 4.
6. **Note cross-item findings** in working context, then write them into PROGRESS.md and ultimately the SUMMARY/synthesis doc.
7. **Honor time budget protocol** — soft cap, handoff-clean exit.
8. **Write SUMMARY.md or PHASE_N_SUMMARY.md** after all items complete.

### What conductors explicitly do NOT do

These rules are absolute. A conductor that violates them is doing executor work and should stop:

1. **No source-code reading.** That's executor work. If you need to know what's in a file, spawn an executor.
2. **No web fetches.** That's executor work.
3. **No grep / glob / search of the codebase.** That's executor work.
4. **No spike code execution.** That's executor work.
5. **No "I'll just check this one thing first."** No. Spawn an executor.
6. **No combining multiple plan items into a single Agent call.** One executor per item.
7. **No skipping plan items because they "seem covered."** Plan is authoritative; if an item's no longer needed, write a conductor decision into PROGRESS.md and explain.
8. **No remembering context from prior sessions.** Read PROGRESS.md and the plan; assume nothing else.

### Conductor allowed tools

- `Read` — for plan docs, foundational docs, PROGRESS.md, executor output files
- `Edit` / `Write` — for PROGRESS.md, SUMMARY.md, and conductor-relay artifacts only
- `Agent` — for executor spawning
- `Bash` / `PowerShell` — only for time checks (`date` / `Get-Date`) and trivial filesystem operations (`mkdir -p` for output directories)

`Glob`, `Grep`, `WebFetch`, `WebSearch`, source-code `Read` of arbitrary files: NOT conductor tools. If the conductor needs information from outside the plan or PROGRESS.md, that's an executor task.

### Anti-pattern: investigator drift

The most common conductor failure mode is "let me just read this one file to confirm" — followed by 30 minutes of investigation that an executor should have done in a fresh context. **The fix is structural, not motivational:** don't keep reading-tool calls in the conductor's working set. If a conductor finds itself about to read a source file, that's the signal to spawn instead.

---

## 3. Agent invocation patterns

The Agent tool's `model` parameter has historically been the trickiest aspect of the pattern. **As of 2026-04-30 the Claude Code subagent docs document direct full-model-ID support; the empirical inheritance workaround used during the daemon-research run is still valid but no longer the only path.**

### Current rule (2026-04-30)

Per `https://code.claude.com/docs/en/sub-agents` § "Choose a model":

> The `model` field controls which AI model the subagent uses:
> - **Model alias**: Use one of the available aliases: `sonnet`, `opus`, or `haiku`
> - **Full model ID**: Use a full model ID such as `claude-opus-4-7` or `claude-sonnet-4-6`. Accepts the same values as the `--model` flag
> - **inherit**: Use the same model as the main conversation
> - **Omitted**: If not specified, defaults to `inherit` (uses the same model as the main conversation)

Resolution order:
1. `CLAUDE_CODE_SUBAGENT_MODEL` environment variable
2. The per-invocation `model` parameter
3. The subagent definition's `model` frontmatter
4. The main conversation's model

### Model handling table

| Item Model | How to invoke | Notes |
|---|---|---|
| **Opus 4.7 1M** | OMIT `model` parameter (executor inherits from conductor on Opus 4.7 1M) — **OR** pass `model: "claude-opus-4-7[1m]"` if confirmed working in your environment | The omit-and-inherit form is **empirically validated** and the safer default; the full-model-ID form per current docs is allowed once verified once per environment. |
| **Opus 4.7 (200K context)** | `model: "opus"` (alias) or `model: "claude-opus-4-7"` (full ID) | Note: the alias `opus` resolves to Opus 4.7 200K, NOT the 1M variant. |
| **Sonnet 4.6** | `model: "sonnet"` (alias) or `model: "claude-sonnet-4-6"` (full ID) | |
| **Haiku 4.5** | `model: "haiku"` (alias) or `model: "claude-haiku-4-5"` (full ID) | Use for mechanical counting, arithmetic, simple cataloging. |

**Default rule for Opus 4.7 1M items: OMIT the `model` parameter.** The inheritance behavior is the empirically-validated mechanism that worked across the daemon-research run with model identity verified for all 11 executors. Even though current docs document `claude-opus-4-7[1m]` as a literal full-model-ID value, the omit-and-inherit form has documented production history; switch to the full-ID form only after confirming it works once per environment.

### Standard executor invocation shape

```python
Agent(
  description: "<short description>",         # under 60 chars
  subagent_type: "general-purpose",           # see § 3.5
  prompt: "<see § 3.6 Executor Prompt Template>",
  model: "<sonnet|haiku|claude-opus-4-7|...|OR omit for Opus 4.7 1M inherit>",
  # Optional:
  run_in_background: true,                    # for long-running spikes / idle tests
)
```

### When this rule may need re-verification

- **New Claude Code release** changes `claude-opus-4-7[1m]` literal handling. Re-test by spawning a trivial executor with that exact `model` value and reading its self-reported model identity (§ 5).
- **`CLAUDE_CODE_SUBAGENT_MODEL` env var** is set by anyone in your shell. The env var overrides the per-invocation `model` parameter — verify it's not set before assuming inheritance worked.
- **First conductor session in a new environment.** Run a smoke-test executor (see § 5.4) before spawning the real ones.

### subagent_type

`general-purpose` is the default for all conductor/executor work in this protocol. Custom subagent types can be defined per the upstream docs but are out-of-scope for this standard — an executor working from a plan doc has its full instructions in the prompt and doesn't benefit from a frontmatter-defined subagent.

### Parallelism

The conductor MAY spawn multiple Agent calls in parallel where the dependency graph permits. Reference instances:
- Daemon research: 5 concurrent in wave 1, 4 in wave 2, 2 in wave 3.
- Phase 1 standards: up to 7 concurrent in wave 1 (all independent items).

**Soft cap: 5 concurrent foreground executors per session.** Token burn rate matters even with unlimited token budget; conductor working memory degrades when juggling more than ~5 outstanding return-summaries. Long-running background tasks (`run_in_background: true`) don't count against the foreground cap.

---

## 4. PROGRESS.md format

The PROGRESS.md is the conductor's state tracker and the resume-protocol entry point. It lives in the plan's working directory (e.g. `<housecarl>/PHASE_1_PROGRESS.md`, `<old>/research/PROGRESS.md`).

### Required sections

1. **Header** — link to plan; last-updated timestamp
2. **Status legend** — see below (canonical text)
3. **Items table** — one row per plan item
4. **Cross-item findings** — conductor jots connections during the run; final synthesis lives in SUMMARY.md
5. **Session log** — one entry per session
6. **Handoff notes** — used when a session ends mid-plan; consumed by the next session's resume protocol

### Status legend (canonical)

```
- `pending` — not yet started
- `in_progress` — executor spawned, working (also long-running background spikes)
- `complete` — output report written, conductor reviewed
- `partial` — executor returned with documented blockers; output is incomplete but useful
- `blocked` — could not start (missing precondition, unresolvable resource issue)
- `locked` — Aaron reviewed and approved as final (use for standards/lock-required artifacts)
```

`locked` is reserved for artifacts that require an explicit human sign-off step (e.g., Phase 1 standards). For pure-research outputs without a lock step, `complete` is the terminal state.

### State transitions

```
pending ──► in_progress ──► complete
                       │
                       ├─► partial   (executor returned with documented blockers)
                       │
                       └─► blocked   (could not start; precondition missing)

complete ──► locked  (only when an explicit lock-step exists for this artifact)

partial / blocked  may transition back to pending  if the blocker resolves.
                                       (Note in session log when this happens.)
```

A status field is **never** edited backward without a session-log note explaining why. If an item moved `complete → partial` because re-review found gaps, document the trigger.

### Items table format

```markdown
| ID | Title | Status | Model | Output | Started | Completed | Notes |
|----|-------|--------|-------|--------|---------|-----------|-------|
| P1.1 | Skill authoring patterns | complete | Opus 4.7 1M | standards/HOUSECARL_SKILL_AUTHORING.md | 2026-04-30 13:27 | 2026-04-30 13:54 | Headline: action-first descriptions; cross-ref P1.2 |
```

Required columns:
- `ID` — matches the plan item identifier
- `Title` — short noun phrase from the plan
- `Status` — one of the legend values
- `Model` — model the executor ran on (verified on return)
- `Output` — path to the output file
- `Started` — local timestamp when Agent call was issued
- `Completed` — local timestamp when conductor finished review (NOT when executor returned — the gap is when the conductor read the output and updated PROGRESS.md)
- `Notes` — at most 2 lines: one-sentence headline, optional cross-ref tag

### Session log

Append-only. One entry per session. Format:

```markdown
- **YYYY-MM-DD HH:MM start** — Items completed this session: [P1.1, P1.2, ...]. Wave structure: <how parallelism shaped up>. Time used: X min wall-clock. Notes: <interesting deviations, model-verification surprises, blockers raised>.
```

If a session ends mid-plan, the session log entry MUST also identify the resume entry point ("Next session resumes at: P1.7, blocked on P1.8 lock") and the next session writes the matching "Resumed from handoff note YYYY-MM-DD" entry.

### Handoff notes

Empty when the conductor completes the plan in a single session. Populated when a session ends mid-plan. Format:

```markdown
**YYYY-MM-DD HH:MM session end — handoff to next session**

State at exit:
- Last item completed: P1.X
- In-flight at exit: <item or none>
- Pending after handoff: P1.Y, P1.Z

Next session entry point:
- First action: <concrete first command, e.g., "Resume P1.Y per § N of plan">
- Watch for: <anything brittle — e.g., "executor environment may have stale CLAUDE_CODE_SUBAGENT_MODEL — verify with a smoke-test agent first">
```

---

## 5. Self-verification protocol

The single most important discipline in this pattern is verifying the executor ran on the model the plan assigned. The cost of running an Opus-4.7-1M-context-required item on Sonnet 4.6 is silent quality degradation; the cost of catching the mismatch on return is one re-spawn.

### 5.1 Mandatory return-summary first line

Every executor prompt MUST include this directive:

> **FIRST ACTION — model identity check:** Before doing anything else, output a single line as the FIRST line of your final return summary identifying the model you are running on, in the format:
> `Running on: <model name>` (e.g. `Running on: Opus 4.7 1M context` or `Running on: Sonnet 4.6`)
> This lets the conductor verify the right model was selected. Do this even if everything else fails.

The first line must be exactly `Running on: <model>` — no preamble, no markdown header, no "Hello, ". Conductor verification reads literally the first line.

### 5.2 Conductor verification step

When an executor returns, the conductor's first action is reading the return-summary first line and comparing to the assigned model.

| Expected | Actual on return | Action |
|---|---|---|
| Opus 4.7 1M | `Running on: Opus 4.7 1M context` | ✅ proceed |
| Opus 4.7 1M | `Running on: Opus 4.7` (no "1M context") | ⚠️ inheritance preserved variant family but not 1M context. Note in PROGRESS.md as "model variant mismatch — content should still be valid but 1M-essential reads may be incomplete." Continue. Do NOT re-spawn (likely environmental). |
| Opus 4.7 1M | `Running on: Sonnet 4.6` | ❌ wrong model. Re-spawn. Most likely cause: env var `CLAUDE_CODE_SUBAGENT_MODEL` set to sonnet, OR the conductor itself is on a non-Opus model. |
| Sonnet 4.6 | `Running on: Sonnet 4.6` | ✅ proceed |
| Sonnet 4.6 | anything else | ❌ wrong model. Re-spawn. Verify the `model: "sonnet"` parameter was set. |
| Haiku 4.5 | `Running on: Haiku 4.5` | ✅ proceed |

**Re-spawn protocol:** if the model is wrong, the executor's work product may still be usable for non-context-essential items (e.g., a Sonnet executor on what was supposed to be Haiku is overkill but not wrong). For Opus-1M items, however, the 1M context is often the load-bearing reason — re-spawn rather than accept.

### 5.3 Output validation

Beyond model identity, the conductor's review of an executor's output should check:

1. **Output file exists at the expected path.** If missing, the executor failed to write — read the return summary for the failure mode.
2. **Output conforms to the "Expected output structure" specified in the plan.** If the plan said five sections and the output has three, that's a partial.
3. **Headline finding stated.** Per executor template (§ 6), the return summary includes a one-sentence headline. The output file should match.
4. **Blockers documented if claimed.** If the return summary says "partial: X blocker," the output file's "Blockers" section should match.

### 5.4 Smoke-test pattern (first executor of a new session)

When a new conductor session starts in an unfamiliar environment, spawn a trivial smoke-test executor BEFORE spawning a real plan item:

```
Agent(
  description: "Smoke test — model identity verification",
  subagent_type: "general-purpose",
  prompt: "Output exactly two lines:
    Line 1: Running on: <your model name>
    Line 2: smoke ok",
  # omit model for Opus-1M inheritance test
)
```

A 5-second smoke test catches `CLAUDE_CODE_SUBAGENT_MODEL` env-var contamination, plugin-config issues, or unexpected resolution-order changes before they affect a real plan item. Skip only if the same conductor has spawned a verified-correct executor earlier in the same session.

### 5.5 What if the executor doesn't return the "Running on:" line?

The executor's return summary doesn't start with `Running on: <model>`. Cases:

1. **Executor encountered a fatal error before reaching the return-summary instruction.** Read the actual return for the failure mode; mark the item `partial` or `blocked`.
2. **Executor wrote a return summary that ignored the directive.** The directive is in the prompt template (§ 6); if missing, the conductor's prompt is malformed — fix and re-spawn.
3. **Executor put the line elsewhere in its output.** Strict rule: if it's not the first line, it doesn't count for verification. Re-emphasize the "FIRST line, no preamble" requirement when re-spawning.

---

## 6. Executor Prompt Template

The canonical executor prompt. Annotated and parameterized — every `<...>` is a substitution point the conductor fills.

### 6.1 Template

```
You are an executor for <project> <phase/run-name> — <item ID and title>.

CRITICAL: The very first line of your return summary MUST be "Running on: <model name>" using your actual model identity. <Optional model expectation reminder, e.g., "You should be on Opus 4.7 1M (inherited from the conductor)."> This lets the conductor verify the right model was selected. Do this even if everything else fails.

CONTEXT:
<2-4 sentences explaining the project, current phase, and why this item matters. Pulled from FOUNDATION.md / plan doc; do NOT make the executor re-derive the project's purpose. The executor will read the foundational docs in full — this section is the orientation for the work, not a substitute for those docs.>

MANDATORY READING (in full):
<List every doc the executor must read. Be explicit about file paths. Order matters; list in the order the executor should read them. Include the plan doc, the relevant phase plan if separate, FOUNDATION/CLAUDE/RATIONALE per the project's reading-order convention, and any reference instances the executor will pattern-match against.>

ASSIGNMENT:
<One paragraph stating exactly what the executor will produce. State the output path. State the methodology section in the plan doc the executor follows.>

METHODOLOGY:
<Either: refer to the plan doc's per-item methodology and don't restate it (preferred — keeps the prompt short),
 OR: paraphrase the methodology in 3-5 numbered steps. Don't both restate AND refer to the plan; pick one to be authoritative.>

OUTPUT STRUCTURE:
<Either: refer to the plan doc's "Expected output structure" section and don't restate,
 OR: list the required sections of the output file. Same rule as METHODOLOGY — pick one.>

QUALITY BAR:
- <3-6 bullets stating what "good" looks like for this output.>
- E.g., "Standard must be self-contained — future readers apply this without having read this conversation."
- E.g., "Cite sources where applicable (URL, file path)."
- E.g., "Tone: authoritative, concrete, operational."

CONSTRAINTS:
- Do NOT <list scope-violations the executor must avoid>
- Do NOT modify files outside <output directory>
<Add project-specific constraints — e.g., "Do NOT write Housecarl source code", "Do NOT modify the old Claude_MO2 repo".>

If you hit a genuine blocker (missing data, build failure, irreconcilable ambiguity), document it under a "Blockers" section in your output file, mark the item as `partial: <reason>` in your return summary, and return. Don't escalate to the conductor mid-task — the conductor reads return summaries, not interim status.

RETURN SUMMARY (3-8 sentences):
- First line: "Running on: <model>"
- What you produced (file path + brief description of the output's shape)
- Key decisions / headline finding (one to a few sentences)
- Cross-item findings — anything you noticed that overlaps with other items in the plan
- Any blockers, missing resources, or unresolved ambiguities

Begin by reading <first mandatory doc>.
```

### 6.2 Annotations

- **Length:** the prompt itself should run 300-1200 tokens. If you're writing a 3000-token prompt, the work is probably small enough to do in-session — or the plan doc is missing detail that the prompt is compensating for.
- **Reading list discipline:** every doc on the mandatory list should actually be necessary. Padding the list with "READ THESE TOO" docs costs executor context window. The conductor's job is to pre-filter what the executor needs.
- **Methodology vs plan-reference:** the plan doc is authoritative. If the prompt restates methodology, drift is possible. Prefer "follow the methodology in PLAN.md § <item>" over restating; if the restating is necessary, mark in the prompt that the plan doc is authoritative on conflicts.
- **Output path:** state the absolute path. Do not say "write to standards/HOUSECARL_*.md" — say `C:\Users\compl\Documents\Claude\Projects\Housecarl\standards\HOUSECARL_FOO.md`. Path ambiguity is a common executor confusion.
- **No version history.** The prompt is not the place to tell the executor about prior versions or rejected alternatives — that's plan-doc material. Keep prompts focused on what to do, not how the project got here.

### 6.3 Anti-confusion directives — canonical text

These boilerplate directives may be copy-pasted verbatim into prompts. They surfaced as fix-paths for common executor failure modes; using them by reference saves rederiving the lesson.

#### For executors

> **Do NOT try to remember context from prior sessions.** Read the mandatory docs; assume nothing else.

> **Do NOT write Housecarl source code.** Phase 1 produces standards docs only. The Housecarl repo doesn't exist yet — that's Phase 3.

> **Do NOT modify files outside `<output directory>`.** If you find yourself needing to edit something outside that scope, document it under "Blockers" in your output and stop.

> **Do NOT escalate to the conductor mid-task.** The conductor reads return summaries, not interim status. If you hit a blocker, document it and return.

> **Cite sources.** URLs, file paths, line numbers where applicable. The conductor and downstream readers can't verify claims without sources.

#### For conductors

> **You are an ORCHESTRATOR, not an investigator.** Your only research action is spawning executor agents via the Agent tool. You do NOT read source code, fetch web docs, or grep through codebases yourself.

> **One executor per item.** Each Agent call covers exactly one plan item.

> **If you're unsure what to do next: re-read PLAN.md.** Don't guess. The plan is authoritative.

> **Verify model identity on every return.** The first line of the return summary is `Running on: <model>`. If it doesn't match the assigned model, re-spawn (for Opus-1M and other context-essential items) or note-and-continue (for non-essential items).

> **Don't escalate to Aaron unless an item is genuinely blocked by missing information or a destructive action would be required.** Otherwise: complete the plan and stop.

---

## 7. Cross-references to other Phase 1 standards

This protocol intersects other Phase 1 standards:

- **HOUSECARL_DOC_HYGIENE.md (P1.3)** — PROGRESS.md is itself a doc that lives somewhere in the repo. Per § 4 it lives in the plan's working directory; per the doc-hygiene standard it's classified as **LIVING** during a plan run (must reflect current state) and transitions to **ARCHIVE** when the plan completes (frozen historical record). The conductor SHOULD NOT edit a PROGRESS.md after the plan archives.
- **HOUSECARL_RELEASE_CADENCE.md (P1.5)** — phase-pattern shipping work IS the application of this protocol to release work. The PHASE_N_HANDOFF.md docs and the per-phase double-commit + hash-record convention are the release-cadence-shaped instance of the conductor/executor pattern. The two standards must compose: a release conductor follows P1.4 for executor spawning AND P1.5 for commit/handoff structure.
- **HOUSECARL_SKILL_AUTHORING.md (P1.1) + HOUSECARL_MCP_AUTHORING.md (P1.2)** — both touch on action-first description shape. Executor prompts share that bias: lead with the work, not the project's history.
- **HOUSECARL_REPO_LAYOUT.md (P1.7)** — the canonical location for plan archives, PROGRESS.md files, and conductor-relay docs is locked by P1.7. This protocol is content-shape; P1.7 is path-shape. They must be consistent.

---

## 8. Reference instances (canonical examples to study)

When in doubt about how a particular pattern applies, study the reference instance:

| Pattern | Reference instance |
|---|---|
| Multi-item research run | `<old-workspace>/research/PLAN.md` + `PROGRESS.md` + `SUMMARY.md` (daemon-architecture research, 2026-04-29 — 11 items, 5-wide parallelism, single-session completion). |
| Phase 1 standards research (this run itself) | `<housecarl>/PHASE_1_PLAN.md` + `PHASE_1_PROGRESS.md` + `PHASE_1_SUMMARY.md` |
| Multi-phase shipping work | `<old-repo>/dev/plans/v2.9.X_condition_parameters/` (most elaborate; 6 phases including 2A/2B split). Contains CONDUCTOR_KICKOFF.md, per-phase KICKOFF_PROMPT and HANDOFF docs, MATRIX.md verification structure, and architectural CONDITIONS_AUDIT.md sub-doc. |
| Multi-phase shipping with conductor relay | `<old-repo>/dev/plans/v2.9.2_read_side_efficiency/PHASE_1_HANDOFF.md` — model handoff from Phase 1 executor to conductor with Q1-Q6 design lock + perf data + cross-product amendment landing. |
| Single-session description-only ship (counter-example: when NOT to do multi-phase) | `<old-repo>/dev/plans/v2.9.5_descriptions_redesign/PHASE_1_HANDOFF.md` — single doc, single session, deliberately broke the multi-phase pattern. |

---

## 9. Quick-start checklist for a new conductor

For a conductor starting a new plan:

1. **Read the plan in full.** Don't skim.
2. **Read PROGRESS.md.** If it doesn't exist, create it from the plan's template.
3. **Read this protocol.** Don't assume you remember it.
4. **Check `CLAUDE_CODE_SUBAGENT_MODEL` env var.** If set, decide whether to unset (for normal operation) or accept (if intentional). Document either way in the session log.
5. **Smoke-test executor** (§ 5.4) if this is a new environment.
6. **Identify the dependency graph** from the plan. Identify which items can run in parallel.
7. **Spawn wave 1** — all independent items, up to soft cap of 5 concurrent.
8. **As executors return:** verify model identity, read output file, update PROGRESS.md, note cross-item findings.
9. **Spawn wave 2 / wave 3** as dependencies clear.
10. **At time-budget threshold:** stop spawning, allow in-flight to complete, write handoff note, exit.
11. **At plan completion:** write SUMMARY.md per the plan's synthesis spec.

---

## 10. Sources

- `https://code.claude.com/docs/en/sub-agents` (formerly `https://docs.anthropic.com/en/docs/claude-code/sub-agents`) — current subagent docs; verifies model parameter accepts full model IDs as of 2026-04-30, with `inherit` as the documented default-when-omitted.
- `<old-workspace>/research/PLAN.md` — the cleanest production-validated reference instance of this pattern, particularly its "Master Conductor Role", "Agent Invocation Patterns", and "Executor Prompt Template" sections.
- `<old-workspace>/research/PROGRESS.md` — production-validated PROGRESS.md shape; the items table format, status legend, and session log conventions in § 4 derive from this.
- `<old-workspace>/research/SUMMARY.md` — production-validated cross-item synthesis shape; the "Verdict / Headline Findings / Cross-Item Connections / Recommended Next Steps / Open Questions / Per-Item Reports / Session Log" structure carries forward to Phase 1's synthesis.
- `<old-repo>/dev/plans/v2.9.X_condition_parameters/PHASE_1_KICKOFF_PROMPT.md` — production-validated executor kickoff prompt with concrete halt-and-report triggers, working-pattern propose-then-execute, CONDUCTOR ASK escalation format. Pattern reinforcement: shipping conductors use the same template; the protocol does not bifurcate by work type.
- `<housecarl>/REBUILD_RATIONALE.md` § Signal 4 — model-inheritance rule was empirically discovered during the daemon-research kickoff rather than known up-front. This protocol's existence prevents that rediscovery cost on future projects.
- `<housecarl>/PHASE_1_PLAN.md` § "Master Conductor Role" + "Agent Invocation Patterns" + "PHASE_1_PROGRESS.md template" — Phase 1's own plan applies this protocol to itself; the recursion is intentional.
