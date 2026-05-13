# PDV_STANDARDS — Project Standards for PlayerDevotion

**Scope:** Operating rules for the PlayerDevotion (PDV) Skyrim SSE mod project. Distilled from the inherited HOUSECARL_*.md standards (now in `archive/`), scoped down to a single-author Skyrim mod context.

**Read this once at session start.** Re-read § 1 (Document Hygiene) and § 4 (Investigation Discipline) when in doubt — they're the load-bearing rules.

---

## 1. Document Hygiene

The repo runs a two-class document system: **LIVING** docs that always reflect current project state, and **ARCHIVE** docs that are frozen at creation. Every `.md` file is one or the other; there is no third class.

### 1.1 LIVING docs (exhaustive list)

| Doc | Purpose | Update when |
|---|---|---|
| `AGENTS.md` | Project context, file map, current build status, decisions log | Architecture changes, build status advances, decision lands |
| `PDV_MOD_SETUP.md` | Dev environment, tooling, variable reference, build order | Tool version changes, new variable added, build step changes |
| `PDV_Architecture_v2.md` | Architecture spec, data model, quest topology, phase plan, revision log | Architecture changes, phase status changes, major design decisions |
| `PDV_Phase*_*.md` | Phase-specific CK/test walkthroughs and summaries | Phase implementation, CK wiring, or testing workflow changes |
| `PDV_SkyrimConsoleReference.md` | Skyrim console command reference for testing | Console command source correction or new verified test command |
| `PDV_STANDARDS.md` (this file) | Operating rules | A rule changes; an anti-pattern is observed; a new rule is needed |
| `references/PAPYRUS_KNOWLEDGE_INTAKE.md` | Papyrus/API/source-layer guidance | Papyrus reference strategy changes or new verified API-source learnings |
| `references/PDV_RaceArchitecture_DesignReference.md` | Race architecture reference and pre-matrix design requirements | Race theology decisions, curse behavior, quest weighting, reward contract, or signal-matrix requirements change |
| `references/phase4/*.md`, `references/phase4/*.csv` | Phase 4 matrix scaffold, signal matrixes, and cross-validation notes | Matrix scope changes, stance/Daedric crosswalk changes, or implementation-facing Phase 4 design decisions land |
| `references/skyrim-deity-reference.jsx` | Cross-cultural deity table | Lore correction surfaces; new pantheon mapping needed |
| `references/tamriel-daily-worship-4e201.html` | Race-by-race daily practice source | Should not change — third-party source design doc |
| `skills/*/SKILL.md` | Local Codex workflow skills for repeated PDV tasks | Repeated workflow pain changes, project paths change, or skill instructions drift |

Anything not on this list is ARCHIVE or should not exist in the repo.

### 1.2 ARCHIVE rules

ARCHIVE = frozen historical record. Currently:

- `archive/HOUSECARL_AGENT_PROTOCOL.md`
- `archive/HOUSECARL_DOC_HYGIENE.md`
- `archive/HOUSECARL_MCP_AUTHORING.md`
- `archive/HOUSECARL_SKILL_AUTHORING.md`

**Immutability:** Files in `archive/` are not edited after first commit. If a fact in an archive doc is wrong, the correction goes in the relevant LIVING doc — not back into the archive. The archive is a timestamped record; editing it retroactively makes the historical record unreliable.

**Exception:** Typo fixes only, noted in commit message as `[archive typo-fix]`. No content additions or removals.

### 1.3 Adding a new doc

Before creating any new top-level `.md`:

1. Confirm the content doesn't fit in an existing LIVING doc. Most additions belong inside `AGENTS.md` (decisions log, file map updates) or `PDV_MOD_SETUP.md` (tooling/architecture extensions), not as new files.
2. If a new file is genuinely needed, classify it: LIVING goes at root; ARCHIVE goes under `archive/` with a dated/contextual filename (e.g. `archive/race-design-nord-2026-05-09.md`).
3. Update the table in § 1.1 if it's LIVING.

**No "see X.md" index docs.** A doc whose only purpose is to point at another doc is a staleness amplifier — when the target moves, the index lies. `AGENTS.md` is the natural navigation aggregation point.

---

## 2. Anti-Patterns to Avoid

Every entry below is a failure mode worth catching at authoring time, not at review.

### 2.1 Parallel doc drift

Don't create a second LIVING doc that duplicates content already in another LIVING doc. If `PDV_MOD_SETUP.md` defines variable conventions, `AGENTS.md` references that doc rather than restating. Two parallel sources always drift.

### 2.2 Version markers in player-facing text

MCM page descriptions, spell tooltips, blessing/neglect descriptions, and any in-game message describes **current** behavior. They never narrate history.

- Doesn't ship: `"NEW in v0.3: Nord blessings now scale with Talos affinity"`
- Ships: `"Talos's favor strengthens with open devotion. Higher devotion deepens the blessing."`

Version history goes in `AGENTS.md` § Decisions Log and (eventually) the public mod page changelog. Not in the spell description.

### 2.3 Internal jargon in consumer surfaces

A blessing's description tells the player what it does, in player terms. It does not name internal records, scripts, hooks, or buckets.

- Doesn't ship: `"Fired by SMF_JoinedCompanions hook when CombatBucket > +5"`
- Ships: `"After joining the Companions in good standing, your strikes carry Hircine's notice."`

Internal mechanism belongs in code comments, trace messages, and `PDV_MOD_SETUP.md`. Never in MCM, spell tooltips, or in-game messages.

### 2.4 All-caps imperative stacks

In design docs, build notes, and decision logs: **don't** write `ALWAYS DO X. NEVER DO Y. THIS IS MANDATORY.` It degrades fast — the moment the situation drifts from what you imagined when writing, the rule breaks brittle. Imperative + reasoning travels:

- Doesn't ship: `"NEVER call StorageUtil from OnInit. EVER."`
- Ships: `"Call StorageUtil from OnPlayerLoadGame, not OnInit. OnInit doesn't run on subsequent loads, so registration there silently fails after save/reload."`

Reserve bolded warnings for genuinely destructive actions with no recovery path.

### 2.5 Phase / sprint / "WIP" markers in shipped surfaces

`"Phase 1 candidate"`, `"WIP race module"`, `"v0.3.x roadmap"` — these tags describe internal dev process and have no meaning to a player. If something ships, it's not WIP. If it's WIP, it doesn't ship. Track in-flight work in `AGENTS.md` § Current Build Status, not in MCM text or doc bodies that other sessions will read as authoritative.

### 2.6 "See X.md for details" inside player-facing surfaces

A spell description that says `"See the readme for full effect details"` is a defect. The player isn't reading the readme mid-fight. Self-contained or it didn't ship.

(Internal docs cross-link freely — that's a different layer.)

---

## 3. Player-Facing Description Discipline

Anything the player will read at any point is a description-engineering surface. Apply the same rules across all of them.

### 3.1 Surfaces that count

- MCM page descriptions and option labels
- Spell records: blessing tooltips, neglect effect tooltips, debug spell readout
- Magic effect descriptions
- In-game messages (`MessageBox`, `Notification`, journal entries if any)
- Race-flavor text in shrine interactions or dialogue

### 3.2 The rules

1. **Action-first lead.** Sentence 1 says what the player gets / what changes, in player terms. No preamble, no internal context.
2. **Player vocabulary.** Use what the player already knows: race names, deity names, Skyrim place names. Avoid `PDV_`, `DevotionLevel`, `bucket`, `hook`, `quest stage`, etc.
3. **Concrete over abstract.** "Frost resistance +25% in Eastmarch" beats "Improved cold tolerance in your homeland."
4. **Cap at ~200 chars for tooltips, ~500 for MCM descriptions.** Forces precision; respects screen space.
5. **No version markers, no phase tags, no `[DEPRECATED]` left behind.** (See § 2.2, § 2.5.)
6. **No emojis or decorative Unicode.** Tokens cost nothing to the engine but degrade tone.

### 3.3 Worked examples

**Blessing description — conforms:**
> "While Talos is honored openly, your shouts carry the old breath of dragons. Shout cooldowns reduced by 15%."

**Blessing description — doesn't conform:**
> "v0.3 Nord blessing tier 3. Triggered when DevotionLevel ≥ 85 and PDV_SMF_TalosAffinity is set. Reduces Shout cooldown via SPEL_NordHighDevotion magic effect."

**Neglect description — conforms:**
> "The Hist's silence weighs on you, far from Black Marsh. Health regeneration slowed."

**Debug spell readout — conforms (single screen, scannable):**
> ```
> Devotion: 67 (Faithful)
> Combat:    +2  Social:    -1  Lifestyle:  +3
> Last shift: +1  (yesterday at dawn)
> Active:    Nord blessing (Mid)
> ```

**Debug spell readout — doesn't conform (textbook):**
> Multi-paragraph explanation of the formula, the bucket caps, the descriptor thresholds, and the SMF list. Move that to `PDV_MOD_SETUP.md` and let the spell stay scannable.

### 3.4 Papyrus trace messages

Same rules apply, scaled down:

- Always prefixed `[PDV]` (already in setup doc).
- State the event + key value(s). Past tense, concrete.
- One line per trace.

**Conforms:** `Debug.Trace("[PDV] ProcessDawn: DevotionLevel " + before + "->" + after + ", dailyShift " + shift)`

**Doesn't conform:** `Debug.Trace("Now executing the dawn processing routine for the bucket reduction calculation phase")`

Strip or gate behind a `bDebugMode` global before any release.

---

## 4. Investigation Discipline

Before claiming a script behaves a certain way, claiming a record is configured a certain way, or recommending a fix:

### 4.1 Verify with tools, not with assumptions

| Question | Cheapest way to actually know |
|---|---|
| What is `DevotionLevel` right now? | Run the debug spell; or `cgf "Debug.GetGlobal" "PDV_DevotionLevel"` |
| Did `ProcessDawn` fire? | Search `Papyrus.0.log` for `[PDV] ProcessDawn` |
| What's actually in the SMF flag record? | Open the ESP in xEdit and read the field value |
| Is the quest running at all? | `sqv PDV_MasterQuest` in console |
| Did my last edit compile? | Check VS Code Problems panel; check the Papyrus output dir for fresh `.pex` mtime |
| Is this happening on a clean save or only mine? | `coc qasmoke` from main menu, test there |

### 4.2 Don't reason about behavior from script source alone

A trace tells you what actually happened in 5 seconds. Reading source and inferring behavior is slower and error-prone — especially with `RegisterFor*` events whose firing depends on registration order, save state, and engine quirks. **Add a trace, run the test, read the log.**

### 4.3 Don't reason about record state from CK alone

CK shows what you intend; xEdit shows what's actually on disk. They diverge surprisingly often (overrides from masters, ESL flag stickiness, dirty edits, ITM records). For any non-trivial conflict question, open xEdit.

### 4.4 Test on the dev profile, ship-test on the testing profile

`PDV_Development` profile is for iteration — extra mods, debug spell, full traces. `PDV_Testing` is the clean profile that mirrors what a player would have. **Final verification happens on `PDV_Testing`.** A change that passes only on Development is not yet shipped.

---

## 5. Decision Logging

Architectural and design decisions live in `AGENTS.md` § Decisions Log. One entry per decision. Format:

```markdown
**[YYYY-MM-DD] — [Topic]:** [Decision]. Rationale: [why this over the alternatives that were on the table].
```

The rationale is load-bearing. A decision without a "why" looks arbitrary in three months and gets overturned by a future-you who has forgotten the constraint that originally drove it.

When a decision affects build steps, dev environment, or variable conventions, mirror it into `PDV_MOD_SETUP.md` in the relevant section.

---

## 6. Safety Rules

### 6.1 Vanilla ESPs are untouchable

`Skyrim.esm`, `Update.esm`, `Dawnguard.esm`, `HearthFires.esm`, `Dragonborn.esm` — never edit directly. All overrides are made in `PlayerDevotion_Framework.esp` or a race module ESP. This is not a guideline; it's how the mod composes with everyone else's load order.

### 6.2 Profile discipline

`Devotion Dev` (inside the Anvil MO2 instance) is the active iteration profile. Keep it minimal — Skyrim/DLC, SKSE, SkyUI, and PDV plugins only — so unexpected behavior can be attributed to PDV rather than another mod. A clean ship-verification profile (`PDV_Testing` or similar) is recommended before any public release; for personal/internal use the dev profile is sufficient. The normal play profile is never touched by PDV files.

### 6.3 No external file changes without an MO2 refresh

If files in MO2-managed mod folders change via Bash, an external editor, or any path other than MO2 itself, MO2 may not detect them until F5. Prefer MO2-aware paths (writing through CK, writing through VS Code's configured output dir into a registered mod folder, etc.). After any external change, refresh MO2 before launching CK or the game.

### 6.4 Compile cleanly

Treat Papyrus warnings as errors during dev. A `.psc` that compiles with warnings ships warnings. Many warnings are real (unused property, mismatched cast, suspicious comparison) — fix them at authoring time.

### 6.5 Strip debug before release

Trace messages and the debug spell are dev tools. Either remove them or gate them behind a `bDebugMode` global in MCM before any public release. A player's `Papyrus.0.log` filling with `[PDV]` traces is a defect, not a feature.

---

## 7. Agent Invocation (Optional)

If a Claude session ever needs to spawn a subagent (e.g., to draft trigger conditions for one race module while iterating on another in the main session), use the template below. Skip this section entirely until that need arises — it's not required for solo work.

### 7.1 When to spawn

Spawn a subagent when:
- The work is independently scoped and produces a written output the main session will synthesize.
- The work would otherwise burn 30%+ of the main session's context.
- Each parallel item benefits from a fresh context window.

Don't spawn when:
- A single-session inline pass would do (most PDV work).
- The agent prompt would itself need >2,000 tokens of project context to be self-contained.

### 7.2 Executor prompt template

```
You are working on PDV (PlayerDevotion), a Skyrim SSE mod that tracks the
player's religious devotion based on race-authentic theology. [1-2 sentences
of additional task context — what this specific item is for.]

CRITICAL: The first line of your return summary must be "Running on: <model>"
using your actual model identity. This lets me verify the right model was
selected. Do this even if everything else fails.

MANDATORY READING (in this order):
- C:\Users\Admin\Documents\Devotion\Claude.md
- C:\Users\Admin\Documents\Devotion\PDV_STANDARDS.md
- C:\Users\Admin\Documents\Devotion\PDV_MOD_SETUP.md
- C:\Users\Admin\Documents\Devotion\references\<the relevant reference file>
- [any other doc this specific task needs]

ASSIGNMENT:
[One paragraph stating exactly what you will produce. State the output path.]

QUALITY BAR:
- Output stands alone — a future session reading this without the conversation
  context can act on it.
- Player-facing strings follow PDV_STANDARDS § 3 (action-first, player
  vocabulary, no internal jargon).
- Cite sources where applicable (file paths, line numbers, deity-reference
  rows).

CONSTRAINTS:
- Do NOT modify files outside the output path.
- Do NOT edit anything in archive/.
- Do NOT add version markers or phase tags to player-facing text.

If you hit a genuine blocker (missing data, irreconcilable ambiguity), document
it under a "Blockers" section in your output and return.

RETURN SUMMARY (3-8 sentences):
- First line: "Running on: <model>"
- What you produced and where
- Key decisions
- Any blockers

Begin by reading Claude.md.
```

### 7.3 Verification on return

First line of the return must be `Running on: <model name>`. If it doesn't match the assigned model, re-spawn (the subagent's work product may still be useful, but inheritance/env vars sometimes route to the wrong model — catch it on return rather than later).

---

## 8. Source Material

The four files under `archive/` are the inherited HOUSECARL_*.md standards from a prior project (an MCP server for Bethesda mod analysis). They are the source material this standard distills from. They contain more detail than PDV needs day-to-day, but if a question arises that this file doesn't cover, they're the next layer to consult — particularly:

- `archive/HOUSECARL_DOC_HYGIENE.md` — the full anti-pattern catalog (AP-1 through AP-7) and rationale for each rule in § 1–§ 2 above.
- `archive/HOUSECARL_AGENT_PROTOCOL.md` — the full conductor/executor pattern, PROGRESS.md format, and self-verification protocol if multi-agent work ever scales up.
- `archive/HOUSECARL_SKILL_AUTHORING.md` — source material for PDV's local Codex skills. Current skill sources live under `skills/`; keep them concise and specific to repeated PDV workflow pain.
- `archive/HOUSECARL_MCP_AUTHORING.md` — applies only if PDV ever grows a tooling MCP component. Currently out of scope.

**Don't copy text from the archive into LIVING docs verbatim.** If a rule from the archive should apply to PDV, restate it scoped to PDV and cite the archive as source. Verbatim copies create the parallel-doc-drift problem § 2.1 exists to prevent.

---

*End of PDV_STANDARDS.*
