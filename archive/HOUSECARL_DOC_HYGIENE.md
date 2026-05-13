# HOUSECARL_DOC_HYGIENE — Doc Hygiene Standard (Living vs Archive)

**Status:** locked 2026-04-30 by Aaron; lock-amended 2026-05-02 at Step 0 (added §1.8 `dev/README.md` per CN-1; broadened §1.7 to explicitly cover PROGRESS.md per CN-2 — both pre-authorized via PHASE_1_SUMMARY.md "Open questions for Aaron" #1+#2 + PHASE_3_PLAN.md Step 0 §10)
**Produced by:** P1.3 executor (Sonnet 4.6), 2026-04-30
**Depends on:** none
**Depended on by:** P1.5 (release cadence — plan archive structure), P1.7 (repo layout — doc locations)

This standard defines the two-class document system for Housecarl: LIVING docs that must always reflect current HEAD state, and ARCHIVE docs that are frozen at creation. It replaces the `feedback_conductor_doc_audit` pattern (pre-ship mandatory doc audit) with structural rules that prevent staleness rather than catch it post-facto.

**Authoritative scope:** Every `.md` file in the Housecarl repo is either on the LIVING list below or is ARCHIVE. No third class. Files not fitting either class should not exist in the repo.

---

## 1. LIVING Docs — Exhaustive List

Anything not on this list is ARCHIVE or should not exist in the repo.

### 1.1 `README.md` (repo root)

**Purpose:** Consumer-facing install and capability overview. First file a new user or fresh Claude session reads. The entry point to understanding what Housecarl is and how to get it running.

**Who updates when:**
- Any new MCP tool or tool group ships → update capability list section
- Any install step changes (installer filename, prerequisites, config path, MCP server setup) → update install instructions
- Version number bumps → update install link / version badge
- Any tool or capability is retired → remove or strike through from capability list
- Migration instructions change (from Claude_MO2) → update migration section

**Staleness check rule:** Run `grep -n "v[0-9]\+\.[0-9]\+\.[0-9]\+" README.md` and verify every version reference matches the current release tag. If any mention of a capability, tool name, or config path does not match the current codebase, README is stale. This check is part of the pre-ship gate (see Section 4).

**Example of staleness:** Claude_MO2 v2.9.1 shipped without updating README to remove a reference to `kb/KB_Tools.md`, which was retired in v2.9.5. The file existed in README for four releases. Housecarl's README must be updated in the same commit that changes the thing it describes.

---

### 1.2 `CLAUDE.md` (repo root)

**Purpose:** Operational rules for any Claude session opening in the Housecarl repo. Read by Claude Code automatically at session start. Contains server availability checks, standing rules for safe operation (patch overrides vs in-place edits), tool usage conventions, and KB/skill routing.

**Who updates when:**
- Any MCP tool usage rule changes (new safe-use constraints, new batch guidance, new CELL/WRLD-class warnings) → update standing rules
- Tool routing changes (which query tool to use for which task) → update relevant rules section
- The skill list changes (new skill added, old skill retired) → update the skills reference
- New environmental quirk is confirmed (MO2 restart requirements, timeout settings) → add to rules
- A tool is removed or renamed → remove or rename references

**Staleness check rule:** Every `mo2_*` / `housecarl_*` tool name mentioned in CLAUDE.md must exist in the current tool registry (`tools_*.py` `@mcp.tool` registrations). Run `grep "housecarl_[a-z_]*" CLAUDE.md` and cross-check each name against the tool registry. Any tool name in CLAUDE.md that doesn't exist in the registry makes this file stale.

**Constraint:** CLAUDE.md must NOT duplicate content from MCP tool schemas. It points at tools and states usage rules; it does not re-document parameter names, types, or batching behavior. That lives in the tool description (per HOUSECARL_MCP_AUTHORING.md). The Claude_MO2 failure mode was a "Knowledge base" section in CLAUDE.md that duplicated `kb/KB_Tools.md` which duplicated `@mcp.tool` descriptions. Three parallel layers; all three drifted. Housecarl's CLAUDE.md cites the schema as authoritative; it does not reproduce it.

---

### 1.3 `KNOWN_ISSUES.md` (repo root)

**Purpose:** Current-as-of-this-version catalog of known limitations, design trade-offs, and user-visible environmental quirks that are not bugs but need documentation. The "read before filing a bug report" resource.

**Who updates when:**
- A session surfaces a new user-facing limitation or environmental quirk → add it before the ship commit
- A known issue is resolved by a release → move the entry to a "Resolved in vX.Y.Z" subsection or remove
- The "Current as of vX.Y.Z" header becomes stale (new release ships without updating) → update header and review all entries

**Staleness check rule (two-part):**
1. The `Current as of vX.Y.Z` header line must match the version constant in `config.py`. Any mismatch is a staleness flag.
2. Scan for version references in issue descriptions (e.g., "v2.9.x candidate" fix-version slugs). Any slug that precedes the current version and whose fix has not shipped is stale — it should either be updated or removed.

**Claude_MO2 failure mode:** The v2.9.1 cache-hygiene quirk (surfaced twice during the ship session's Phase 3 and Phase 5) was not added to KNOWN_ISSUES.md until a post-ship `[v2.9.1 post-ship]` cleanup commit. The released archive had stale docs. This standard prevents that by making KNOWN_ISSUES.md updates a pre-ship gate item, not a post-ship cleanup.

**Anti-pattern:** Adding exhaustive feature documentation to KNOWN_ISSUES.md. It is for limitations and environmental quirks, not a capability reference. Entries about condition-parameter coverage specifics (like the 113/41/28/11 function counts in the old project) belong in the CHANGELOG or in a dedicated reference, not KNOWN_ISSUES.md.

---

### 1.4 `mo2_mcp/CHANGELOG.md` (or equivalent at `<plugin_src>/CHANGELOG.md`)

**Purpose:** Version-by-version narrative of what changed, why, and what carry-overs remain. The canonical "what actually shipped in vX.Y.Z" record for any session picking up after a release.

**Who updates when:**
- Pre-ship: add the entry for the version being shipped (what changed + rationale, not just what). Entry may be drafted during development and finalized at ship.
- Post-architectural decision: if a decision retroactively explains a prior entry (rare), update the prior entry with a `[See: vX.Y.Z]` pointer rather than rewriting history.

**Staleness check rule:** The topmost entry version number must match the version in `config.py`. If `config.py` says `PLUGIN_VERSION = (1, 2, 3)` and the top CHANGELOG entry is `## v1.2.2`, CHANGELOG is stale.

**Format constraint:** Entries must be past-tense narrative, not plan documentation. "Shipped X" not "Will ship X" or "Phase 1 adds X". The distinction matters because plan docs frequently get copied forward into CHANGELOG entries and retain future-tense language, creating confusion about what is speculation and what is shipped.

---

### 1.5 `FOUNDATION.md` (Housecarl prep workspace, then equivalent in Housecarl repo)

**Purpose:** Single source-of-truth for what Housecarl is — vision, architecture (locked), standards (populated by Phase 1), naming, migration policy. The "read this to understand the project at any depth level" doc. No other doc should repeat what's in FOUNDATION.md; they link to it.

**Who updates when:**
- Architecture section: changes require new evidence (new research result, surfaced implementation issue) and explicit commit message rationale. This section is intentionally change-resistant.
- Standards section: populate each TBD entry as the corresponding Phase 1 standard ships. Link to `standards/HOUSECARL_*.md`; do not duplicate content.
- Naming section: populate when P1.8 ships.
- Migration policy: update at Housecarl v1.0 ship.
- **After a research phase closes** (Phase 2.5 daemon-architecture absorb 2026-05-01; Phase 2.7 file-level VFS when it closes; future research phases): refresh the architecture section against the absorbed corpus; cite the absorbed corpus path; preserve Aaron-locked decisions per FOUNDATION.md §"How this document evolves".
- **After a vision-alignment lock** (Q1–Q13 closed 2026-05-01; Q9.1 amendment 2026-05-02): propagate locks into FOUNDATION.md (capability cuts, install layout, out-of-scope list, "How this document evolves" section).

**Staleness check rule:** (a) Architecture section reflects the most recently absorbed research corpus (`dev/research/` for Phase 2.5; `dev/vfs-research/` for Phase 2.7 when it closes). Any architecture claim contradicted by an absorbed corpus item is stale. (b) Capability cuts + install layout reflect all closed Q-locks (currently Q1–Q13 + Q9.1). Any capability claim contradicted by a locked Q is stale. (c) §"File-level VFS" architecture sub-section is research-pending until Phase 2.7 close — it should explicitly flag this state, not present definitive architecture claims.

---

### 1.6 `CLAUDE.md` (Housecarl prep workspace)

**Purpose:** Orientation doc for any Claude session opening this prep workspace (not the Housecarl product repo). Contains current phase, reading order, what is and is not allowed, phase sequence, and old workspace paths.

**Who updates when:**
- Current phase changes → update "Current phase" section
- A phase completes → update phase sequence table
- A foundational decision changes → update the relevant section

**Staleness check rule:** The "Current phase" section must match the actual project state per the most recent `PHASE_N_PROGRESS.md` (PHASE_1_PROGRESS.md for Phase 1; PHASE_2_PROGRESS.md for Phase 2 + 2.5; future phase-progress files when authored) **or** the project's last closed phase entry in CLAUDE.md itself (e.g., the per-phase entries in CLAUDE.md's "Current phase" block that mark each closure date). Cross-check against VISION_ALIGNMENT_PROGRESS.md for vision-alignment Q-lock state and against any phase-execution plan doc (per §1.7) for in-flight phase status. If the most authoritative live source disagrees with CLAUDE.md, CLAUDE.md is stale.

---

### 1.7 Phase-execution plan + progress docs (temporarily LIVING; class rule)

**Class rule (not an exhaustive enumeration):** Plan docs that drive an in-flight execution phase, AND progress docs that track such a phase's execution, are LIVING during execution and ARCHIVE on close. Examples to date: VFS_RESEARCH_PLAN.md (Phase 2.7), STALENESS_AUDIT_PLAN.md (post-vision-alignment audit), STALENESS_AUDIT_REPORT.md (this audit's output), PHASE_3_PLAN.md (Phase 3 spine), PHASE_3_READING_GUIDE.md (Phase 3 per-sub-phase reading prescriptions), PHASE_3_PROGRESS.md (Phase 3 cross-sub-phase progress tracker), and any plan-archive PROGRESS.md or per-conductor-run PROGRESS.md per [HOUSECARL_AGENT_PROTOCOL.md §7](HOUSECARL_AGENT_PROTOCOL.md). Each is LIVING from authoring through Aaron lock + execution close, then transitions to ARCHIVE per §2.1 at the close-out commit.

The PROGRESS.md inclusion (lock-amended 2026-05-02 per CN-2) makes the §1.7 class explicitly cover progress-tracking docs — they are phase-scoped LIVING, not stale LIVING and not ARCHIVE-from-start. The per-conductor-run PROGRESS.md described in HOUSECARL_AGENT_PROTOCOL.md §7 fits the same lifecycle.

**Why a class rule, not §1.X enumeration:** New plan-execution docs are authored each phase. Enumerating each one as a §1.X subsection would create churn-by-design — every phase adds a new subsection that gets retired weeks later. The class-rule approach keeps §1 stable: phase-execution plan docs are LIVING under this single rule until their close, then they cross the §2.1 boundary and become ARCHIVE without needing §1 amendment.

**Who updates when (during LIVING window):**
- The plan/report's authoring conductor or executor updates as phase work progresses
- Aaron lock-pass decisions land as inline annotations or appended decision sections
- At execution close, the doc is committed in its final state and the next commit (with `[ARCHIVE typo-fix]` exception aside) cannot edit it

**Staleness check rule:** Phase-execution plan docs are stale if (a) the in-flight phase has closed but the doc has not been committed in final state, OR (b) post-close edits have landed without `[ARCHIVE typo-fix]` flag. Hook coverage (§3.1) catches case (b) once the doc enters its post-close commit window.

**Examples of LIVING→ARCHIVE transitions to date:**
- VISION_ALIGNMENT_PROGRESS.md (LIVING during Sessions N–N+2 vision-alignment grilling; ARCHIVE-sealed at Session N+3 close 2026-05-01)
- VFS_RESEARCH_PLAN.md (LIVING during Phase 2.7 research-plan authoring; LOCKED 2026-05-01; ARCHIVE on Phase 2.7 execution close)
- STALENESS_AUDIT_PLAN.md (LIVING during plan authoring; LOCKED 2026-05-01; ARCHIVE on Session N+5 close)
- STALENESS_AUDIT_REPORT.md (LIVING during Session N+4 audit + Session N+5 lock-pass; ARCHIVE on lock-pass close)

---

### 1.8 `dev/README.md` (declares archive territory)

**Purpose:** Declares that `dev/` is archive-class territory; navigates Claude sessions to current state in root LIVING docs; documents the dev/ subdirectory map per [HOUSECARL_REPO_LAYOUT.md §3.9](HOUSECARL_REPO_LAYOUT.md). The "this is an append-only historical record. Current state lives in the repo root LIVING docs" anchor that AP-3 (Section 6) names as the prevention rule.

**Who updates when:**
- A new dev/ subdirectory type is introduced (e.g., a new `dev/<phase-slug>-research/` corpus is absorbed)
- An existing subdirectory's purpose or status changes (e.g., LIVING → ARCHIVE transition for a phase-execution doc that previously sat at top-level)
- The "current state lives in" pointer set changes (e.g., a new root LIVING doc is added per §5.1)

**Staleness check rule:** The subdirectory map table in `dev/README.md` reflects the actual `dev/` directory contents. If a subdirectory is present in the filesystem but absent from the map (or listed in the map but missing from the filesystem), `dev/README.md` is stale. Surfaced 2026-04-30 during P1.7 review (CN-1, PHASE_1_SUMMARY.md); landed via lock-amendment 2026-05-02 at Step 0.

---

## 2. ARCHIVE Rules

Everything that is not on the LIVING list above is ARCHIVE. Archive docs are:

### 2.1 Immutability After Creation

**Rule:** An ARCHIVE doc is immutable from the moment it is committed. No edits after first commit. If information in it is wrong, the correction belongs in a new doc or in a LIVING doc that supersedes it — not in an edit to the archive doc.

**Rationale:** Archive docs are timestamped records of decisions and state at a point in time. Editing them retroactively makes the historical record unreliable. A session reading an archive should be able to trust that it accurately represents what was known and decided at its creation date.

**Enforcement:** The pre-commit hook described in Section 4 checks whether any file in an `archive/` or `dev/plans/` or `dev/session-handoffs/` or `dev/session-summaries/` path is being modified in a non-initial commit. It blocks the commit and reports the offending file path.

**Exception:** Typo fixes in ARCHIVE docs are permitted if the typo makes the doc ambiguous or misleading. Such edits must be noted in the commit message as `[ARCHIVE typo-fix]` and no content may be added or removed — only the erroneous text corrected.

**Examples of LIVING→ARCHIVE transitions (canonical reference):**
- **Top-level path retention:** VISION_ALIGNMENT_PROGRESS.md transitioned LIVING→ARCHIVE at Session N+3 close (2026-05-01) but stays at top-level prep-workspace path for cross-doc citation stability. The transition did NOT move the file under `dev/` — only its mutability class changed. Phase 3 migrate-plan moves it into `dev/rebuild-prep/` per CLAUDE.md §1.2.
- **Research-corpus absorb-commit ARCHIVE:** `dev/research/outputs/T*.md` (daemon-architecture corpus) became ARCHIVE from the Phase 2.5 absorb commit (2026-05-01). They were ARCHIVE upon arrival — never had a LIVING window in this workspace. Same pattern for `dev/vfs-research/outputs/V*.md` (Phase 2.7 corpus when produced).
- **Phase-execution plan close-out:** VFS_RESEARCH_PLAN.md transitions from LIVING (during plan authoring) to ARCHIVE (at execution close). See §1.7.

---

### 2.2 Naming Convention

**Rule:** All archive docs follow this naming pattern:

```
<CONTEXT>_<DESCRIPTION>_<DATE>.md
```

Where:
- `CONTEXT` = version slug or feature slug or phase slug (e.g., `v1.0.0`, `daemon-research`, `P0`)
- `DESCRIPTION` = what this doc is in 1-4 words, snake_case (e.g., `PLAN`, `PHASE_1_HANDOFF`, `MATRIX`, `CONDUCTOR_KICKOFF`)
- `DATE` = ISO date `YYYY-MM-DD` **only when the same CONTEXT + DESCRIPTION combination could recur** (session summaries, session handoffs, freeform reports)

For per-release plan archives (which are already namespaced in a versioned folder), the date in the filename is optional — the folder name provides the release context. For session summaries and handoffs, the date is required because the same session type recurs.

**Examples (correct):**
- `dev/plans/v1.0.0_daemon_foundation/PLAN.md` — no date needed, folder namespaces it
- `dev/plans/v1.0.0_daemon_foundation/PHASE_1_HANDOFF.md` — no date needed
- `dev/session-handoffs/SESSION_HANDOFF_2026-05-15.md` — date required (same type recurs)
- `dev/session-summaries/SESSION_SUMMARY_2026-05-15.md` — date required

**Examples (incorrect, never do this):**
- `dev/plans/v1.0.0_daemon_foundation/Phase1Handoff.md` — mixed case, no underscore separation
- `dev/session-handoffs/handoff.md` — no context, no date, ambiguous
- `dev/reports/Capability_Roadmap_2026-04-16.md` — this is fine structurally but "reports" is a general catch-all that creates the sprawl problem; see Folder Conventions below

---

### 2.3 Folder Conventions

**Rule:** Archive docs live in exactly one of these locations. No freeform archive folders.

```
dev/plans/<version-slug>_<feature-slug>/      — per-release plan archives
dev/session-handoffs/                          — per-session pickup context
dev/session-summaries/                         — per-session what-actually-happened
dev/<phase-slug>-research/                     — per-research-phase corpus (e.g., dev/research/, dev/vfs-research/)
dev/<phase-slug>-research/outputs/             — per-research-phase per-item executor outputs (T1.1_*.md, V2.5_*.md, etc.)
dev/<phase-slug>-research/followups/           — per-research-phase post-close follow-up tracking
dev/<phase-slug>-research/spikes/              — per-research-phase executable spike code (e.g., dev/vfs-research/spikes/V1.3_*.cs)
dev/rebuild-prep/                              — pre-Phase-3 prep workspace contents (migrated to repo at Phase 3 scaffold per CLAUDE.md §1.2)
```

The `dev/reports/` catch-all folder from Claude_MO2 is **abolished**. Reports that are research outputs go into the plan archive they belong to or into a dedicated `dev/<phase-slug>-research/` folder. There is no orphan reports bucket.

**Rationale:** The old `dev/reports/` folder in Claude_MO2 accumulated 18 files over the project's life, ranging from structured audit outputs to freeform exploratory notes. A session looking for a specific report had to scan all 18 to determine relevance. Removing the catch-all forces every archive doc to be placed in context: either it belongs to a specific release or research effort, or it's a session handoff/summary.

**Research archives (canonical pattern):** For research phases that follow the conductor + executor pattern (Phase 2.5 daemon-architecture, Phase 2.7 file-level VFS), archive lives at `dev/<phase-slug>-research/` with the established `T<N>.<M>_<slug>.md` (Phase 2.5) or `V<N>.<M>_<slug>.md` (Phase 2.7) per-item naming. The `outputs/`, `followups/`, `spikes/` subdirectories are conventional, not mandatory — use whichever the research-phase plan defines. Each `dev/<phase-slug>-research/` folder is ARCHIVE per §2.1 from absorb commit (Phase 2.5) or initial commit (Phase 2.7+ where the corpus is generated in-place).

---

### 2.4 Max-Count Guidelines Per Release

**Rule:** Per-release plan archives (`dev/plans/<version-slug>_<feature-slug>/`) must not exceed the following file counts:

| Release type | PLAN.md | MATRIX.md | CONDUCTOR_KICKOFF.md | PHASE_N_HANDOFF.md files | Supporting docs (AUDIT.md, etc.) | TOTAL cap |
|---|---|---|---|---|---|---|
| Single-session (docs/config only) | 1 | — | — | 1 | — | 2 |
| Standard feature release | 1 | 1 | 1 | up to 8 | up to 2 | 13 |
| Complex multi-component release | 1 | 1 | 1 | up to 12 | up to 4 | 19 |

**Rationale:** Claude_MO2's largest release archives (v2.9.0 conditions, v2.9.2 read-side efficiency) each topped 9 files. The v2.6.0 mutagen migration and v2.8.0 verification archives each approached or exceeded 10. The max-count cap is not about arbitrary restriction — it is about forcing discipline in what goes into the archive vs what belongs in session handoffs. Every file added to a plan archive should be referenced by the PLAN.md or PHASE_N_HANDOFF.md chain. If it isn't, it's an orphan that inflates session-startup reading time.

**Exception trigger:** If a release genuinely requires more files than the cap allows (new toolchain, multi-subsystem refactor), the conductor must get explicit agreement from Aaron before exceeding the cap, with the rationale stated in the PLAN.md's scope section.

---

### 2.5 What Goes in Plan Archives vs Living Docs

**Rule:** A decision belongs in a plan archive if it was made for this release specifically. A decision belongs in a LIVING doc if it applies to all future development.

**Test:** Ask "would a session working on vX.Y.Z+1 need to know this?" If yes, it belongs in a LIVING doc or auto-memory. If it only applies to vX.Y.Z specifically, it belongs in the plan archive.

**Examples:**
- "v1.2.0 ships with replace-semantics on Effects arrays" → CHANGELOG (living), not plan archive
- "The v1.2.0 discriminator decision was option A vs B vs C and Aaron chose A for these reasons" → plan archive PHASE_0_HANDOFF.md
- "All future `set_fields` writes use replace-semantics for list properties" → KNOWN_ISSUES.md or FOUNDATION.md, not plan archive
- "MO2 restart required after Python edits" → KNOWN_ISSUES.md, not plan archive

---

## 3. Enforcement Mechanism

### 3.1 Pre-Commit Hook: `doc-hygiene-check`

**Recommended implementation:** A Python script at `tools/hooks/doc_hygiene_check.py`, invoked from `.git/hooks/pre-commit`.

**What it checks:**

1. **LIVING doc currency checks (fast):**
   - Parse `config.py` for `PLUGIN_VERSION = (X, Y, Z)` → extract current version string `vX.Y.Z`
   - Check `KNOWN_ISSUES.md` first line for `Current as of vX.Y.Z` — if the extracted version doesn't match, emit: `FAIL: KNOWN_ISSUES.md header says 'Current as of vA.B.C' but config.py says vX.Y.Z. Update the header before committing.`
   - Check `CHANGELOG.md` topmost `## vX.Y.Z` entry — if doesn't match current version, emit: `WARN: CHANGELOG.md top entry is vA.B.C but config.py says vX.Y.Z. Is there a changelog entry for this release?`
   - Both of these are fast string-grep operations; no semantic parsing required.

2. **ARCHIVE immutability check:**
   - For every file path in the staged changeset that matches `dev/plans/**`, `dev/session-handoffs/**`, `dev/session-summaries/**`, `dev/research/**`, `dev/vfs-research/**`, `dev/<word>-research/**` (per the research-archive pattern in §2.3), or `dev/rebuild-prep/**`, check whether the file existed in `git log --follow -- <path>` before this commit (i.e., it has prior commits). If it does, it's an ARCHIVE edit violation.
   - Emit: `FAIL: <path> is an ARCHIVE doc and has been modified. Archive docs are immutable after first commit. If this is a [ARCHIVE typo-fix], add that flag to your commit message to bypass this check.`
   - Bypass: if the commit message contains `[ARCHIVE typo-fix]`, skip this check for files in archive paths.

3. **ARCHIVE naming check:**
   - For every NEW file added in `dev/session-handoffs/**` or `dev/session-summaries/**`, verify the filename matches the pattern `SESSION_(HANDOFF|SUMMARY)_\d{4}-\d{2}-\d{2}(_.+)?\.md`. If it doesn't, emit: `FAIL: <path> doesn't match archive naming convention. Expected SESSION_(HANDOFF|SUMMARY)_YYYY-MM-DD[_slug].md`

4. **Orphan doc check (warning-only):**
   - For every NEW file added in `dev/plans/<release-folder>/`, verify that either `PLAN.md` or at least one `PHASE_N_HANDOFF.md` in the same folder already exists (staged or committed). If neither exists, emit: `WARN: <path> is being added to a plan archive with no PLAN.md or PHASE_N_HANDOFF.md. Is this doc orphaned?`

**Rationale for Python over shell:** Shell pre-commit hooks are OS-sensitive and break on Windows (the target platform). A Python script can be cross-platform. It should use only stdlib (no pip dependencies for a commit hook). The hook is approximately 80-100 lines of stdlib Python; it runs in <100ms on typical commit sizes.

**Installation:** The `build/` directory contains a `setup-hooks.py` (or equivalent) that installs the hook into `.git/hooks/pre-commit`. New dev environment setup includes running this script. FOUNDATION.md's "dev setup" section (when written) links to this.

**Scope boundary:** This hook catches structural violations. It does not check whether the _content_ of LIVING docs is accurate — that remains a human responsibility at the pre-ship gate. The hook prevents the class of failures that can be detected mechanically (version number mismatches, archive edits, naming violations).

---

## 4. Pre-Ship Gate (Non-Hook Enforcement)

The pre-commit hook is necessary but not sufficient. Content-level staleness requires human judgment. The pre-ship gate formalizes this.

**Rule:** Before the ship commit for any version (the commit that bumps `config.py`'s `PLUGIN_VERSION`), the conductor must explicitly verify:

1. `KNOWN_ISSUES.md` — read in full. Verify every entry is still accurate for the version about to ship. Add any session-surfaced limitations that were not added at discovery time. Update the "Current as of" header to the new version. **This step is required even if the conductor believes no entries need changing** — the explicit "audited clean" log matters.

2. `CHANGELOG.md` — verify the top entry for the version being shipped is present, complete, and in past tense.

3. `README.md` — skim for stale version references, stale capability claims, stale install paths.

4. `CLAUDE.md` — spot-check that every `housecarl_*` tool name mentioned exists in the current tool registry.

**Anti-pattern explicitly named:** The `[vX.Y.Z post-ship]` cleanup commit. If the pre-ship gate runs, post-ship cleanup commits should not occur. If one does occur, it represents a gate bypass — the commit message must include `[GATE-BYPASS reason: ...]` to make the bypass visible in git history.

**Timing:** The audit runs before the work commit that includes `config.py`'s version bump. Audit fixes are folded into that same commit. The tag is applied after the commit that includes the audit fixes. The GitHub release archive therefore always contains accurate docs.

---

## 5. Migration Policy

### 5.1 Adding a New Living Doc

**Procedure:**
1. A session identifies a need for a new LIVING doc (e.g., a class of information that doesn't fit any existing LIVING doc and would be re-discovered by future sessions without it).
2. Conductor escalates to Aaron with: (a) the proposed doc name, (b) the purpose in one sentence, (c) which existing doc this supplements/replaces if any, (d) what triggers an update.
3. Aaron approves or rejects.
4. If approved: the doc is added to this standard (HOUSECARL_DOC_HYGIENE.md) in the LIVING list. A Phase N plan archive records the addition (if during a release) or the conductor records it in PHASE_1_PROGRESS.md cross-item findings (if during Phase 1).
5. The pre-commit hook is updated to include the new doc in currency checks if applicable.

**Anti-pattern:** Quietly adding a new `.md` to the repo root without updating this standard. That is the organic-sprawl vector. New root-level `.md` files require explicit registration here.

---

### 5.2 Retiring a Living Doc

**Procedure:**
1. A LIVING doc becomes candidates for retirement when: (a) its content is fully superseded by another LIVING doc or by tool schemas/skill descriptions, OR (b) the thing it documents no longer exists in the codebase.
2. Retirement means: move to `dev/archive/` with a `_RETIRED_vX.Y.Z.md` suffix appended to the filename. Do NOT delete — the historical record is preserved; it simply no longer lives at a root location where sessions auto-load it.
3. Update CLAUDE.md to remove any reference to the retired doc.
4. Update this standard (HOUSECARL_DOC_HYGIENE.md): move the entry from the LIVING list to a "Retired" section.
5. Update FOUNDATION.md if the doc was referenced there.

**Example (old project):** `KNOWLEDGEBASE.md` was a 10-line index pointing at `kb/KB_Tools.md`. When `kb/KB_Tools.md` was retired in v2.9.5 (superseded by MCP tool schemas), `KNOWLEDGEBASE.md` should have been simultaneously retired. It was deleted outright, which is correct functionally but loses the historical record. Housecarl's policy is to retire to archive rather than delete.

---

### 5.3 Reclassifying an Archive Doc as Living

**Rule:** This is not permitted. An archive doc, once created, cannot be promoted to LIVING status. If the need for a LIVING doc arises on a topic an archive doc covers, create a new LIVING doc that synthesizes the archive's content as of the relevant date. The archive doc remains immutable.

**Rationale:** Allowing reclassification would erode the archive's immutability guarantee. The new LIVING doc is the synthesis; the archive doc remains the timestamped record.

---

## 6. Anti-Pattern Catalog

Each entry names a specific failure from Claude_MO2 v2.9.x with its root cause, and states the Housecarl rule that prevents recurrence.

---

### AP-1: Parallel KB Layer (kb/KB_Tools.md)

**What happened:** `kb/KB_Tools.md` (160 lines) duplicated content from MCP tool `@mcp.tool` descriptions. When v2.9.2 shipped batch parameters, they were added to the tool schemas but not to `KB_Tools.md`. A live consumer Claude ran 3,500 sequential `mo2_record_detail` calls because the schema had the batching guidance but KB_Tools.md (which it loaded first) didn't. Two parallel authoritative sources, one drifted.

**Root cause:** A second documentation layer was created alongside the first without a rule forbidding duplication and without any coupling between the two layers (updating one did not require updating the other).

**Housecarl rule:** CLAUDE.md points at MCP tool schemas as authoritative. No `kb/KB_Tools.md` equivalent. No LIVING doc may duplicate content that lives in MCP tool descriptions or skill bodies. If information needs to be findable from both CLAUDE.md and the schema, CLAUDE.md says "see the tool schema for X" — it does not reproduce X.

---

### AP-2: Post-Ship Cleanup Commits

**What happened:** During the v2.9.1 ship, a cache-hygiene quirk was surfaced twice during testing (Phase 3 preflight and Phase 5 Step 3). The pre-ship doc audit did not exist as a formal step; `KNOWN_ISSUES.md` was not updated during the ship. After tagging, Aaron prompted the audit; a `[v2.9.1 post-ship]` cleanup commit was made. The released archive (GitHub release artifact) contained stale docs; only `main` had the fix.

**Root cause:** No pre-ship gate. Doc audit was informal ("someone will remember") rather than mandatory and gated.

**Housecarl rule:** Pre-ship gate in Section 4 is mandatory. The ship commit (`config.py` version bump) may not be made until the gate is passed. Post-ship cleanup commits for LIVING doc staleness are a failure mode, not an acceptable cadence. If one occurs, it must be logged as a gate bypass.

---

### AP-3: Session-Context Docs Mistaken for Current State

**What happened:** Multiple sessions read old session handoffs and session summaries, picking up stale operational context as if it were current. The `feedback_dev_startup.md` memory had to be created explicitly to tell sessions "read the repo docs, not just the handoffs." The existence of that memory is evidence the problem was chronic.

**Root cause:** No explicit distinction between "here is the current state" (LIVING docs) and "here is what was true during a specific session" (archive docs). Session handoffs lived in the same `dev/` subtree as plan archives; their status as time-bounded vs current was implicit.

**Housecarl rule:** All ARCHIVE docs carry a README in their parent folder (per `dev/README.md` convention from Claude_MO2) that states: "This is an append-only historical record. Current state lives in the repo root LIVING docs." The `dev/README.md` rule is documented in this standard and enforced by the repo layout standard (P1.7). Any Claude session starting in the Housecarl repo reads CLAUDE.md first; CLAUDE.md explicitly states "current state lives in README, KNOWN_ISSUES, CHANGELOG, FOUNDATION — not in dev/."

---

### AP-4: Version Markers in Doc Content

**What happened:** In `KNOWN_ISSUES.md`, issue entries carried phrases like "v2.9.x candidate" for fix-target versions. Over multiple releases, these slugs ossified: the fix didn't ship in v2.9.x, but the entry remained labeled as a v2.9.x candidate. A session reading KNOWN_ISSUES.md in v2.9.4 would see "v2.9.x candidate" and believe the fix was coming soon, when in fact it had already been deferred indefinitely.

**Root cause:** Version-marker language in LIVING docs with no enforcement that the markers be updated when releases ship without those fixes.

**Housecarl rule:** KNOWN_ISSUES.md entries use version markers only for releases that have already shipped ("Covered as of vX.Y.Z"). For open limitations, entries state the limitation without a fix-target slug. If a fix-target is tracked, it goes in a plan archive or issue tracker, not in KNOWN_ISSUES.md. The pre-ship gate (Section 4) explicitly includes a scan for stale "vX.x candidate" language.

---

### AP-5: Plan Archive Accumulation Per Release

**What happened:** Each v2.9.x release produced 5-13 files in its plan archive folder. Over 10 releases in the v2.6.0–v2.9.5 range, this produced approximately 80+ plan archive files. Session startup required loading CLAUDE.md, CHANGELOG.md, KNOWN_ISSUES.md, README.md, the most recent session handoffs, AND the most recent plan archive to understand current state. The more files in each plan archive, the more a session had to read to orient.

**Root cause:** No max-count cap on plan archives. No rule about what belongs in the plan archive vs in LIVING docs or session summaries.

**Housecarl rule:** Max-count guidelines in Section 2.4 cap plan archives at 2 (single-session), 13 (standard feature), or 19 (complex multi-component) files. The decision rule in Section 2.5 defines what belongs in the plan archive vs LIVING docs. Plan archive content is for per-release decisions; cross-release knowledge goes in LIVING docs or auto-memory.

---

### AP-6: DEV_CONTEXT.md (Superseded History)

**What happened (pre-2026-04-18):** Before the repo restructure, a `DEV_CONTEXT.md` file tried to maintain a comprehensive project-state summary. It went stale within days of each release because it was a duplicate of information already in CHANGELOG.md + README.md + KNOWN_ISSUES.md. Maintaining it required manual sync; sessions that read it got stale state.

**Root cause:** A LIVING doc was created to solve a cross-session context problem, but its content overlapped with other LIVING docs. Maintaining multiple docs with overlapping content is structurally unstable — one always lags the others.

**Housecarl rule:** The LIVING list in Section 1 is exhaustive and non-overlapping. If two LIVING docs would contain overlapping content, one of them is wrong: either they should be merged, or one should point to the other as authoritative. The standard is a single source of truth per topic. Before adding a new LIVING doc, verify that its intended content doesn't already live in an existing LIVING doc.

---

### AP-7: KNOWLEDGEBASE.md Index Without Content

**What happened:** `KNOWLEDGEBASE.md` (10 lines) was an index pointing at `kb/KB_Tools.md`. When `kb/KB_Tools.md` was retired in v2.9.5, `KNOWLEDGEBASE.md` was deleted. But for the ~6 months before v2.9.5, a LIVING doc existed whose sole purpose was to point at another doc. If the target was stale, the index was stale too — but there was no coupling between them.

**Root cause:** Index docs (docs that only point at other docs) are a staleness amplifier. Every update to the target requires an update to the index; because the index is a separate file with no automated coupling, it drifts.

**Housecarl rule:** No index-only LIVING docs. If a LIVING doc needs to reference another doc, it does so with a link — it does not exist solely to be an index. CLAUDE.md is the natural aggregation point for navigation; it explicitly says "read X for Y" rather than delegating that to a separate KNOWLEDGEBASE.md wrapper.

---

## 7. Cross-Item Connections

**P1.5 — Release Cadence:** The plan archive structure defined in Section 2 of this standard (folder naming, max-count caps, contents rules) is the primary input P1.5 needs for its plan archive section. P1.5 should reference this standard's Section 2 rather than re-specifying it. The double-commit pattern (work commit + hash-record commit per phase) from Claude_MO2 is orthogonal to doc hygiene — P1.5 owns it.

**P1.7 — Repo Layout:** Section 2.3 (Folder Conventions) specifies where archive docs live (`dev/plans/`, `dev/session-handoffs/`, `dev/session-summaries/`). P1.7 must reflect these paths in the repo layout map. P1.7 also needs to know where LIVING docs live — all five root-level LIVING docs listed in Section 1 are at the repo root or one level down (e.g., `<plugin_src>/CHANGELOG.md`). P1.7 should not invent new doc locations that conflict with this standard.

**P1.4 — Agent Protocol:** Session handoffs and session summaries (ARCHIVE) are the primary output of per-session work under the conductor/executor pattern. P1.4's executor prompt template should reference this standard's naming convention (Section 2.2) for handoff filenames. P1.4's PROGRESS.md format is an ARCHIVE doc (frozen per phase — see Section 2.1) even though it looks like state tracking; the conductor creates new entries but does not retroactively edit completed entries.

**P1.1 — Skill Authoring:** Skills are not `.md` docs in the traditional sense (they're SKILL.md files in `.claude/skills/<name>/`). They are treated as quasi-LIVING: their `description:` frontmatter must reflect current trigger behavior (if the trigger changes, the description must change), and their body must reflect current tool names and patterns. Skills are not ARCHIVE because they evolve with the codebase. P1.1 should reference this standard's CLAUDE.md rule (AP-1) about not duplicating MCP tool descriptions in skill bodies.

---

*End of HOUSECARL_DOC_HYGIENE.md*
