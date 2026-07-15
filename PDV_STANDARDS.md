# PDV_STANDARDS — Project Standards for PlayerDevotion

**Scope:** Operating rules for the PlayerDevotion (PDV) Skyrim SSE mod project. Distilled from the inherited HOUSECARL_*.md standards (now in `archive/`), scoped down to a single-author Skyrim mod context.

**Read this once at session start.** Re-read § 1 (Document Hygiene) and § 4 (Investigation Discipline) when in doubt — they're the load-bearing rules.

---

## 1. Document Hygiene

The repo runs a two-class document system: **LIVING** docs that always reflect current project state, and **ARCHIVE** docs that are frozen at creation. Every **committed** `.md` file is one or the other; there is no third class. (Tool-generated regenerable reports are not committed at all -- see 5.3.)

### 1.1 LIVING docs (exhaustive list)

| Doc | Purpose | Update when |
|---|---|---|
| `README.md` | Minimal repository overview | The public repo tagline or high-level project description changes |
| `Claude.md` | Claude entrypoint that defers to `AGENTS.md` | Claude-specific entrypoint instructions or navigation changes |
| `AGENTS.md` | Project context, file map, current build status, decisions log | Architecture changes, build status advances, decision lands |
| `PDV_MOD_SETUP.md` | Dev environment, tooling, variable reference, build order | Tool version changes, new variable added, build step changes |
| `PDV_Architecture_v2.md` | Architecture spec, data model, quest topology, phase plan, revision log | Architecture changes, phase status changes, major design decisions |
| `PDV_Architecture_v3.md` | Forward architecture, v3 subsystem plan, roadmap to beta and launch | v3 architecture changes, roadmap gates change, beta/launch readiness definitions change |
| `PDV_TargetEndStates_1.0.md` | 1.0 product target, per-race end-state acceptance, and roadmap traceability | Launch target changes, per-race acceptance state changes, end-state roadmap tracking changes |
| `archive/completed-phase-docs-*/README.md` | Archive index for completed phase walkthroughs and summaries | The archive set changes or a completed phase moves out of the root workflow |
| `PDV_SkyrimConsoleReference.md` | Skyrim console command reference for testing | Console command source correction or new verified test command |
| `PDV_STANDARDS.md` (this file) | Operating rules | A rule changes; an anti-pattern is observed; a new rule is needed |
| `references/PAPYRUS_KNOWLEDGE_INTAKE.md` | Papyrus/API/source-layer guidance | Papyrus reference strategy changes or new verified API-source learnings |
| `references/PDV_Anvil_MO2_MCP_Intake.md` | Anvil MO2 MCP tool-surface and setup intake | MO2 MCP endpoint, plugin tooling, or optional binary status changes |
| `references/PDV_BosmerPactModel_Planning.md` | Ratified Bosmer Old Contract / Green Pact model | Bosmer Pact commitment, compliance, violation, or renunciation rules change |
| `references/PDV_V3_Preflight_SmokeChecklist.md` | V3 Preflight smoke-test checklist | V3 Preflight smoke path or acceptance evidence changes |
| `references/PDV_RaceArchitecture_DesignReference.md` | Race architecture reference and pre-matrix design requirements | Race theology decisions, curse behavior, quest weighting, reward contract, or signal-matrix requirements change |
| `references/authoring/*` | Authoring manifests, phase contracts, runbooks, roster authorities, audit ledgers, and implementation-costing backlogs | Authoring contracts, verifier-facing manifests, race audit ledgers, costing queues, content readiness, or phase proof requirements change |
| `references/phase4/*.md`, `references/phase4/*.csv` | Phase 4 matrix scaffold, signal matrixes, and cross-validation notes | Matrix scope changes, stance/Daedric crosswalk changes, or implementation-facing Phase 4 design decisions land |
| `references/vanilla-gameplay/*` | Vanilla Skyrim gameplay mechanics, CK data surfaces, and immersive UX reference backbone | Gameplay source correction, new signal hook source, CK table expansion, UX research update, or PDV gameplay-design implication changes |
| `race-sheets/*.md` | Race-by-race player-facing design sheets and overview | Race architecture, gameplay expression, curse behavior, reward contract, or custom-content priority changes |
| `references/skyrim-deity-reference.jsx` | Cross-cultural deity table | Lore correction surfaces; new pantheon mapping needed |
| `references/tamriel-daily-worship-4e201.html` | Race-by-race daily practice source | Should not change — third-party source design doc |
| `references/tamriel-cursed-worship-4e201.html` | Race-by-race curse-state religious interpretation source | Curse-state lore correction or locked curse interpretation changes |
| `references/tamriel-daedric-worship-4e201.html` | Race-by-race Daedric practice source | Daedric lore correction or locked Daedric-path interpretation changes |
| `docs/agents/*.md` | Agent issue-tracker, triage-label, and domain-doc instructions | Agent workflow metadata, issue tracker, or domain-doc routing changes |
| `native/DevotionPrismaBridge/README.md` | Native Prisma bridge implementation notes | Prisma bridge build, payload, or runtime integration details change |
| `skills/*/SKILL.md` | Local Codex workflow skills for repeated PDV tasks | Repeated workflow pain changes, project paths change, or skill instructions drift |

Anything not on this list is ARCHIVE or should not exist in the repo.

### 1.2 ARCHIVE rules

ARCHIVE = frozen historical record. Currently:

- `archive/HOUSECARL_AGENT_PROTOCOL.md`
- `archive/HOUSECARL_DOC_HYGIENE.md`
- `archive/HOUSECARL_MCP_AUTHORING.md`
- `archive/HOUSECARL_SKILL_AUTHORING.md`
- `archive/Skyrim_Modding_Lessons_2026-05-14.md` - frozen external practical Skyrim/Papyrus lessons intake
- `archive/Skyrim_Modding_Lessons_Full_2026-05-14.md` - expanded frozen external practical Skyrim/Papyrus lessons intake
- `archive/phase-order-recommendations-2026-05-20.md` - frozen planning analysis for the Section 21.5 reduced reorder decision

**Immutability:** Files in `archive/` are not edited after first commit. If a fact in an archive doc is wrong, the correction goes in the relevant LIVING doc — not back into the archive. The archive is a timestamped record; editing it retroactively makes the historical record unreliable.

**Exception:** Typo fixes only, noted in commit message as `[archive typo-fix]`. No content additions or removals.

### 1.3 Adding a new doc

Before creating any new top-level `.md`:

1. Confirm the content doesn't fit in an existing LIVING doc. Most additions belong inside `AGENTS.md` (decisions log, file map updates) or `PDV_MOD_SETUP.md` (tooling/architecture extensions), not as new files.
2. If a new file is genuinely needed, classify it: LIVING goes at root; ARCHIVE goes under `archive/` with a dated/contextual filename (e.g. `archive/race-design-nord-2026-05-09.md`).
3. Update the table in § 1.1 if it's LIVING.

**No "see X.md" index docs.** A doc whose only purpose is to point at another doc is a staleness amplifier - when the target moves, the index lies. `AGENTS.md` is the natural navigation aggregation point.

### 1.4 CK walkthrough authoring

When writing manual CK steps, optimize for how the user actually moves through
the editor rather than for abstract grouping.

1. Order steps in the same sequence someone should click through in CK.
2. Keep one menu/dialog together before jumping to another menu/dialog.
3. Inside long property or field lists, sort entries alphabetically unless the
   UI itself is meaningfully ordered another way.
4. If a list is intentionally not alphabetical, say why so the reader knows it
   is deliberate rather than drift.

The goal is lower CK friction. A technically correct walkthrough that forces the
reader to hunt around an unsorted property list is still a bad walkthrough.

### 1.5 Smoke test definition

When a phase asks for a "smoke test," treat that as the full closeout test
needed to mark the phase done unless the request explicitly says otherwise.

That means a smoke test should include the phase's real acceptance path:

1. startup/bootstrap sanity where relevant
2. the core functional proof, not just one happy-click check
3. boon/effect grant and removal behavior where applicable
4. any rivalry/hostility or cross-ledger behavior the phase introduced
5. save/load sanity on the proven final state

If a debug or console route has not already been proven in this setup, prefer
the surfaced in-mod debug path over inventing a new console flow mid-test.

### 1.6 Locked design ratification loop

When a lore review, planning pass, or implementation review locks a design
decision, ratify it across the living docs in the same session. Do not leave a
new rule stranded in chat, a branch-only patch, or one planning note when
other living docs will still be read as authoritative.

Minimum ratification pass:

1. Update the narrowest authoritative design source first.
2. Update every dependent living doc that restates the rule in player-facing or
   implementation-facing terms.
3. Add or update the `AGENTS.md` decision entry with the rationale and the
   prior rule it supersedes, if any.
4. If the decision changes tooling or workflow, mirror it into
   `PDV_MOD_SETUP.md` in the same session.

For race-design work this usually means: the locked planning/design reference,
the affected `race-sheets/*.md` file, any overview sheet that summarizes the
race, and `AGENTS.md`.

### 1.7 Post-merge consistency sweep

After any broad sync or merge that touches multiple race sheets, architecture
docs, or workflow docs, do a short consistency sweep before calling it done.
Big merges are where tiny drift hides.

Minimum sweep:

1. Check that overview labels still match the detailed race sheets.
2. Check that any renamed or superseded rule was updated in every living doc
   that still states it.
3. Check for encoding or ASCII drift in user-visible docs and examples.

The goal is not a second full review. It is a cheap pass that catches the
small follow-up fixes that otherwise appear one commit later.

---

## 2. Anti-Patterns to Avoid

Every entry below is a failure mode worth catching at authoring time, not at review.

### 2.1 Parallel doc drift

Don't create a second LIVING doc that duplicates content already in another LIVING doc. If `PDV_MOD_SETUP.md` defines variable conventions, `AGENTS.md` references that doc rather than restating. Two parallel sources always drift.

A committed copy of a tool-generated report is the same anti-pattern with a build step: the committed rendering drifts from what the tool would emit today, and reconciling the two becomes its own work item. Regenerable reports are never committed (see 5.3).

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

### 2.7 Phantom declarations — shipping the cheap half of a feature

Don't ship the layers of a feature that live in the file you already have open and
leave the layer that needs new detection for "later."

A curated deity signal has four layers:

| # | Layer | Lives in | Cost |
|---|-------|----------|------|
| 1 | `Int Property SIGNAL_X = N AutoReadOnly` | `PDV_Deity_<God>.psc` | trivial |
| 2 | `ScoreCuratedSignal` DELTA branch | `PDV_Deity_<God>.psc` (same file) | trivial |
| 3 | `HumanizeCuratedSignalReason` phrase | `PDV__ManagerQuest.psc` | trivial |
| 4 | **A real caller of `AwardCuratedSignal[Scaled]`** | a detector across `PDV_PlayerEvents` / `PDV_ActionRouter` / `PDV_EventBus` / manager | **design work** |

Layers 1-3 are local edits. Layer 4 is a design. Ship 1-3 and the signal is inert: it
scores, it has a voice, it shows up in every static audit — and it can never pay the
player a single point of piety.

The project's own name for this is a **phantom declaration** (`7368c87f`: *"Every
counted type now fires in-game; no phantom declarations"*). It is not hypothetical: 32
curated signals reached `main` this way, alongside `EVT_STEAL_ITEM`, the SM LockPick
event, and 8 DEAD_PROMISE events. The class has now been caught **eight separate times**
between 2026-06-10 and 2026-07-14 and re-created after every catch.

It recurs for two structural reasons, and neither is carelessness:

1. **Layers 1 and 2 are not merely cheap — they are the same file, and that file is the
   deliverable.** A task of the form "design God X's signal set" *produces*
   `PDV_Deity_X.psc`. Declaring and scoring is what finishing that task looks like.
   Layer 4 lives in four other scripts and is a different discipline (event detection).
   It is not the last 25% of the task; it is a second task that nobody opened.
2. **Nothing charges you for skipping layer 4.** The one gate that sees this class
   (`pdv_signal_e2e_gate --dispatch-coverage-only`) is silenced by adding a line to
   `tools/pdv_reserved_signals.json` — see § 5.2. Zero marginal cost.

The design/build split makes it worse. `PDV_SessionHandoff_DeitySignalRemap_2026-07-08.md`
spends ~270 lines on § 2 "Per-race locked design" (the const + score + phrase spec) and
16 lines on § 3 "Build backlog" (the detectors) — six bullets with no owner, no date and
no status marker. Half of that backlog is still open. **The detector work was not
deprioritized; it was demoted out of the deliverable.**

And because the design pass never has to touch the detector layer, it cannot discover
that a signal is *undeliverable*. `IsCombatSessionOrigin` (`PDV_PlayerEvents.psc`) covers
origins 4,5,6,7,8 only — **Nord, Imperial, Breton, Altmer and Redguard get no combat
session at all.** Every combat-flavoured signature signal designed for those five races
(Shor, Tsun, Stuhn, Leki, Talos) was unbuildable the day it was specced, and the design
doc had no way to notice.

**The rule: a signal, event, or route is not authored until something can fire it.**
No commit may add `Int Property SIGNAL_X` to a `PDV_Deity_*.psc` without adding an
`AwardCuratedSignal[Scaled](PDV_<God>, PDV_<God>.SIGNAL_X, ...)` call site in the same
commit. If you cannot name the detector, you do not have a signal — you have a design
note, and it belongs in the design doc, not in the script. This is `grep`-checkable in a
pre-commit hook, which is the point: the previous seven responses to this class were
prose, and prose got waived.

An unfireable declaration is worse than an absent one, because absence is visible and a
phantom looks like coverage.

**Corollary — an unfired signal has never been tested against the systems it feeds.**
Not the daily cap: `PIETY_DAILY_MAX_DELTA = 4.3` is a *hard* clamp applied at dawn
(`ClampValue(pietyToday * GAIN_RATE_SCALE, -dailyCap, dailyCap)`), so no signal can
blow it and raw delta is not the thing to fear. The thing to fear is **what the signal
feeds on its way there**:

- **The broad-pantheon pool.** `AwardPietyInternal` *auto-opens* a broad-pantheon event
  scope when none is open, and `AccumulateBroadPantheonDelta` takes the **strongest
  applied positive delta per logical event** (ADR-0001). So any curated award on a
  pool-eligible deity (Kyne, Shor, Tsun, Stuhn, Mara, Arkay, Dibella, Talos, and the
  Imperial Eight) raises that event's contribution to the pool. A high-delta signal on a
  *frequent* trigger does not break the per-deity cap — it quietly converts ordinary play
  into broad devotional standing, which is exactly what ADR-0001 exists to prevent.
- **Anti-farm.** `AwardCuratedSignal*` has no internal cap. The cap is always the
  caller's: `ConsumeDailyRepeatMultiplier` (soft `0.7^n` decay) for repeatables, or a
  StorageUtil latch for one-shot milestones (precedent: `97ac3065`, Blood-Kin).

When you move a signal from reserved to wired, its authored delta is a *proposal*, not a
setting. Before it fires, answer three questions: **what triggers it, how often can that
trigger fire, and is its deity pool-eligible?** A +2.5 signal on a rare milestone is
fine; the same +2.5 on "won a hard fight" is a pool leak.

**Corollary — check the cheaper lane first.** Before authoring a curated signal, check
whether the act is already paid by the likes/dislikes CSV or the quest-reaction matrix.
`Nord.md` promises that fair kills please Shor, Tsun and Stuhn — and all three already
take capped CSV piety per humanoid kill. A curated signal for the same act would not
have kept a promise; it would have double-paid one that was already kept.

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
6. **ASCII-only player-facing text.** Skyrim can mangle multibyte characters in UI/dialogue/message pipelines. Use straight quotes, `...`, `--`, `-`, and `*`; avoid curly quotes, em/en dashes, ellipses, bullets, and emojis.
7. **Dialogue line discipline.** Keep spoken dialogue lines under 80 characters where possible, and prefer Skyrim-style full forms over modern contractions.

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

### 3.5 Grammar and style rules

These rules apply to all player-facing surfaces listed in § 3.1. They are the baseline before any writer-review pass. The verifier enforces the two automatable rules (terminal punctuation, contractions); the rest are manual review targets.

**Name capitalisation.** Always capitalise:
- Deity and divine names: Kyne, Talos, Mara, Auri-El, Malacath, Hircine, Riddle'Thar.
- Race names: Nord, Khajiit, Dunmer, Argonian, Orsimer (and Orc as a shorthand).
- Hold, city, and settlement names: Whiterun, Eastmarch, Riften, Solitude, Black Marsh.
- Faction names and named groupings: The Companions, College of Winterhold, Vigilants of Stendarr, Thalmor.
- Named systems and pacts when referenced by title: the Talos ban, the Green Pact, the Wild Hunt, the Civil War, the Concordat.
- Skill names when named explicitly: Smithing, Speech, Alteration.

Do not capitalise generic nouns: "the hall," "a shrine," "the temple," "a blessing." Capitalise only when the word is part of a proper name ("Temple of Mara," "Hall of the Dead").

**Stat notation format.** Mechanical stat changes use numeral + symbol with an explicit sign: "+10%", "-5%", "+15 stamina." Never spell out a stat change: write "+10%" not "ten percent more." Descriptive percentages inside a prose sentence that are not direct stat changes spell out: "five percent of your health." Do not mix conventions in a single string — if the string has a stat line, that line uses the numeral form.

**Terminal punctuation.** Every player-facing string ends with a full stop, exclamation mark, or question mark. No trailing space after the terminal character. The verifier flags missing terminal punctuation as a warning.

**Tense.** Present tense for active effect descriptions: "Kyne shelters the hunter." Timeless narrative for deity acknowledgment: "Kyne has noticed your steps." Do not switch tenses within a single string.

**Contractions.** Do not use modern contractions in any player-facing text. Write "do not" not "don't," "you are" not "you're," "it is" not "it's." The verifier flags known contractions as a warning.

**Oxford comma.** Use the Oxford comma in any list of three or more items: "health, stamina, and magicka" — not "health, stamina and magicka."

**Sentence fragments.** A fragment is acceptable as the mechanical-effect clause at the end of a two-part blessing string: "Kyne has noticed your steps. Cold resistance +10%." The fragment is always the second clause and is always a stat notation line. Do not use fragments in other positions.

---

### 3.4 Papyrus trace messages

Same rules apply, scaled down:

- Always prefixed `[PDV]` (already in setup doc).
- State the event + key value(s). Past tense, concrete.
- One line per trace.
- Temporary debugging traces use `DBG` in the trace text and a nearby `; DEBUG - remove before release` source comment so they can be found and stripped together.

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

### 4.5 Respect save-baked script state

When Papyrus behavior looks impossible after a script change, retest from a new game or a main-menu `coc qasmoke` path before rewriting logic. Old saves can retain stale script instances and properties, so a loaded save may be testing yesterday's state against today's source.

### 4.6 Tooling reality check

If `node` is not on PATH in a PowerShell session, run PDV tools via the Codex-bundled Node runtime:

`C:\Users\Admin\.cache\codex-runtimes\codex-primary-runtime\dependencies\node\bin\node.exe`

### 4.7 Verifier-first regression loop

When a CK, xEdit, MO2, or manual wiring change can regress silently, prefer
adding or tightening verifier coverage before trusting memory or a one-off
smoke pass.

Use this order:

1. Change the script or record.
2. Ask whether the verifier should now assert that state explicitly.
3. Add or tighten the verifier check when the failure would otherwise be easy
   to miss.
4. Run the relevant strict gate before calling the work closed.

If a regression is only detectable by remembering "what looked right last
time," the workflow is still too fragile.

### 4.8 Papyrus compile triage order

When a `.psc` compile fails, classify the problem before editing behavior.
Work in this order:

1. import chain / missing source roots
2. API provenance or wrong function signature
3. Papyrus parser or language-limit violation
4. actual logic bug

This project has repeatedly hit compile failures that looked like logic problems
but were really missing imports, invented helpers, or Papyrus syntax limits.
Treat "the logic is wrong" as the fourth guess, not the first.

### 4.9 Tooling harvest after new work

When the project does something new, review the work while it is still fresh
and ask whether the next pass should be easier, safer, or more repeatable.
This applies to new CK wiring, xEdit edits, runtime proof routes, verifier
checks, helper scripts, source-generation patterns, and manual walkthroughs.

Use this order:

1. Finish or stabilize the immediate work enough that the real pain point is
   visible.
2. Identify what was manual, fragile, repeated, easy to misread, or easy to
   forget.
3. Decide whether the improvement belongs in an existing verifier check, an
   authoring helper, a manifest, a checklist, a local skill, or a living doc.
4. Make the small improvement in the same session when it is low-risk and
   clearly scoped.
5. If the improvement is bigger than the current task, record the follow-up
   with enough evidence that a later session can implement it without
   rediscovering the problem.

Do not turn every one-off into new infrastructure. The bar is repeatability:
if the same kind of work is likely to happen again, or if a future miss would
be expensive to diagnose, harvest the lesson into the workflow.

---

## 5. Decision Logging

Architectural and design decisions live in `AGENTS.md` § Decisions Log. One entry per decision. Format:

```markdown
**[YYYY-MM-DD] — [Topic]:** [Decision]. Rationale: [why this over the alternatives that were on the table].
```

The rationale is load-bearing. A decision without a "why" looks arbitrary in three months and gets overturned by a future-you who has forgotten the constraint that originally drove it.

When a decision affects build steps, dev environment, or variable conventions, mirror it into `PDV_MOD_SETUP.md` in the relevant section.

### 5.1 Completeness claims must cite a gate

A completeness or "scaled out" claim — about a race, a deity, a signal layer,
a reward set, or the backend as a whole — must cite the machine gate that
proves it (e.g. `tools/pdv_completeness_audit.mjs`,
`tools/pdv_paired_equity_audit.mjs`, a strict `pdv_verify` mode, or a named
`--check` helper run), or it is an opinion, and must be written as one.

Rationale: five separate "fully scaled out" claims later proved to have gaps
(BaanDar SGE, stance bake, ScoreAction skew, ProcessDawn trigger, Kyne Part B
profile). Every one was an ABSENCE, and artifact-anchored verification cannot
flag what was never authored — only a contract-driven gate can. Per-component
self-assessment shares the author's blind spot; a citation requirement makes
the blind spot visible instead of fatal. (Ratified 2026-06-10; see
`references/authoring/PDV_CompletenessAudit_Plan.md`.)

**Amendment (2026-07-14) — a gate citation is void if the gate passes by waiver.**
If the gate reports PASS *because* the thing being claimed is covered by a reservation,
waiver, or known-gap ledger entry, the citation proves nothing. Cite the gate **and its
waiver count**. `pdv_signal_e2e_gate` prints `PASS` and `reserved-known-gaps=37` on the
same line; a claim can quote the first half honestly and still be false. Likewise, read
past the summary line: `PDV_SignalE2EGateLedger.md` currently prints `Summary: GREEN=39`
(that count is per-surface) directly above `completenessAudit: FAIL (exit 1)` — a helper
that fails out-of-band without turning the summary red. A green headline over a red
helper is not a passing gate.

### 5.2 Reserved ledgers are debt, not documentation

`tools/pdv_reserved_signals.json`, `pdv_reserved_events.json` and
`pdv_reserved_routes.json` let a declared-but-undispatched item register as a
documented known-gap, so the coverage gate reports PASS instead of FAIL. That is a
legitimate mechanism and a dangerous one: **parking a line is always cheaper than
wiring or cutting**, so the ledger drifts from a to-do list into a silencer.

It already has. Between 2026-07-07 and 2026-07-14 the signal ledger went
33 -> 28 -> 35 -> 38 -> 37: six entries burned by wiring a real trigger, ten added by
parking a new gap. Net +4, gate green throughout. Over the same period the *events*
ledger shrank 12 -> 8. The difference is the lesson: **a ledger silences exactly where
the remaining work is expensive**, because the parked item is by construction the
expensive kind (see § 2.7).

Rules:

1. **Non-increasing.** A commit that adds a reserved entry without removing one is a
   FAIL. This forces a refactor that orphans a dispatch to cut-or-wire in the same
   commit instead of parking the wreckage. Every one of the five curated-signal
   regressions (four `SIGNAL_ANCESTOR_SPINE`, one `SIGNAL_LAWFUL_ORDER`) was a
   *correct* design change that manufactured a new "known gap" on its way out.
2. **Entries are decisions, not descriptions.** Each requires `decision`
   (`wire` | `cut` | `retired`), an `owner`, and an `expires` date. "Wave 3" is not a
   date. A `wire` entry past its expiry FAILs.
3. **`retired` is terminal, not debt.** A signal deliberately superseded by an
   architecture change (substrate conversion, the Breton two-axis split) is not an
   unfinished gap and must not share a bucket with unfinished work. Retiring is a
   decision; reserving is a deferral. Conflating them is how five deliberate,
   defensible removals booked themselves as five outstanding defects.
4. **Removing the last caller is a gate event.** A commit that deletes the final
   `AwardCuratedSignal*` call site for a signal must also delete the constant, the
   score branch and the phrase — or explicitly mark the signal `retired`.
5. **At 1.0 the `wire` and `cut` buckets must be EMPTY**, with the gate defaulting to
   FAIL on any entry. Per the default-fail ruling in `pdv_verify.mjs`: "an opt-in flag
   nobody passes is how the dead-signal class hid."
6. **A ledger reason is a snapshot, not an authority. Re-check it against the newest
   design lock before acting on it.** The ledger deferred Stuhn's two signals as
   low-priority "Wave 3" on 2026-07-06. On 2026-07-13 the pantheon-parity lock
   (`PDV_TargetEndStates_1.0.md`) *promoted* Stuhn to a focusable Old Ways patron "with
   its own offer, rewards, and neglect." Acting on the older note would have stripped a
   Champion-eligible patron down to one lane. Ledger entries go stale in both directions:
   a "cut" can become contracted content, and a "wire" can become dead.
7. **Before cutting, grep the contract ledgers.** A signal that looks vestigial in code
   may be the scaffolding for a written commitment. `PDV_BetaContract.csv` BC-0153
   contracts Syrabane's entire ward/protection lane at `BETA` status — the exact five
   signals a code-only reading marks as dead.

Rationale: § 5.1 established that a completeness claim must cite a gate. The phantom
class is the next failure over — the gate *was* cited, the gate *was* green, and the
gate could be satisfied by the half of the artifact that costs nothing. A gate that
counts declarations measures authoring effort, not player-reachable behavior. **Gates
must count what the player can reach.** (Ratified 2026-07-14; see
`references/authoring/PDV_CuratedSignalDispatch_Forensics_2026-07-14.md`.)

### 5.3 Committed artifact classes: authority, evidence, pipeline state -- reports are regenerable

Every status/proof artifact under `references/authoring/` is exactly one of four
classes (ratified 2026-07-15; see AGENTS.md Decisions Log):

1. **Hand-authored authority** -- written by a person, read by people and gates.
   Committed. Examples: `PDV_1_0_EndStateContract.json`, `PDV_BetaFeelBurndown.md`,
   `PDV_DeityCoverageMatrix.json`, waiver/triage ledgers.
2. **Evidence store** -- irreplaceable manual/runtime proof, merged (never
   overwritten) by intake tools. Committed. Examples:
   `PDV_DaedricRuntimeEvidenceLedger.json`, `PDV_FeltFamilyEvidenceLedger.json`,
   `PDV_InWorldHookProofLedger.json`,
   `PDV_PantheonSubstrateRuntimeEvidenceLedger.json`,
   `PDV_1_0_ManualSignoffLedger.json`, `PDV_PacingSignoffLedger.json`.
3. **Pipeline state** -- machine-read by another tool or by the end-state contract
   (`freshness.sources` or `evidence.read`). Committed. Examples:
   `PDV_1_0_FreshnessStamps.json`, `PDV_SignalE2EGateLedger.csv`,
   `PDV_SignalFloorLedger.csv`, `PDV_P2FormListEspLedger.csv`,
   `PDV_FeltTraceLedger.json`, `PDV_PacingSimLedger.json`,
   `PDV_FinalPlacementLedger.json`.
4. **Regenerable report** -- written by a gate/audit tool, read by no tool and no
   contract. **Never committed.** Gitignored (see the "Ledger-authority
   consolidation" block in `.gitignore`); kept on disk; regenerated by running the
   tool. Examples: `PDV_1_0_EndStateBurndown.md`/`.json`, and every generated `.md`
   twin of a pipeline-state `.csv`/`.json`.

Rules:

1. **Authority is the contract plus a fresh gate run, never a committed rendering.**
   A status claim cites the gate command and its live output, not a copy of a
   report that may be stale.
2. **A file named in the end-state contract's `freshness.sources` or read in read
   mode (`evidence.read`) MUST be committed** -- a fresh clone regenerates reports
   by running tools, but the gate reads these files before any tool runs.
3. **Classify at creation.** A new generated ledger is assigned a class in the
   commit that adds its tool; a pure report gets its `.gitignore` line in that same
   commit.
4. **Never `git add` a regenerable report**, and never treat its absence from git
   as drift to repair. If a report file is missing on disk, run its tool.

Rationale: between 2026-07-07 and 2026-07-14, committed copies of generated
reports (the end-state burndown alone churned 19 commits) still drifted from
reality and manufactured reconciliation work. A committed rendering beside its
machine source is parallel doc drift (see 2.1) with a build step.

---

## 6. Safety Rules

### 6.1 Vanilla ESPs are untouchable

`Skyrim.esm`, `Update.esm`, `Dawnguard.esm`, `HearthFires.esm`, `Dragonborn.esm` — never edit directly. All overrides are made in `Devotion.esp` or a race module ESP. This is not a guideline; it's how the mod composes with everyone else's load order.

### 6.2 Plugin work goes through houseCARL directly

All Skyrim plugin record reads, writes, and verification use the `housecarl_*` MCP tools directly. Do not route through, extend, or rebuild a local wrapper, adapter, bridge, capability matrix, or authoring helper — and do not build new ones. houseCARL is both the writer and the reader: its default lane writes to a new plugin, leaving originals untouched, and verification is a `housecarl_read_record` / `housecarl_cross_plugin_query` readback in the same session. That readback **is** the proof; there is no adapter or proof-ledger step in between.

The legacy authoring layer (`pdv_author.mjs`, `creation-authoring`, all `pdv-*-author`) is retired and deleted from disk. A second, unverified local writer adds risk, not safety — that was the lesson, and it is why the dry-run/backup/proof-ledger pattern must not be recreated. If a doc still tells you to run one of those helpers, the doc is stale.

Before accepting that a houseCARL limitation blocks a task, **reproduce it with a direct call on the current version** and read the actual error. A locally recorded "known issue" is not evidence; only a reproduced, current-version failure is. Full rule and the list of stale beliefs: `AGENTS.md` → "houseCARL v1.7+ Direct Plugin Work Rule".

The one sanctioned programmatic path is the read-only gate scripts (`pdv_housecarl_p2_readback.mjs`, `pdv_pantheon_*_readback.mjs`, via `tools/lib/pdv_housecarl_stdio.mjs`), which speak houseCARL's own MCP protocol for deterministic gates and never write.

### 6.3 Profile discipline

`Devotion Dev` (inside the Anvil MO2 instance) is the active iteration profile. Keep it minimal — Skyrim/DLC, SKSE, SkyUI, and PDV plugins only — so unexpected behavior can be attributed to PDV rather than another mod. A clean ship-verification profile (`PDV_Testing` or similar) is recommended before any public release; for personal/internal use the dev profile is sufficient. The normal play profile is never touched by PDV files.

### 6.4 No external file changes without an MO2 refresh

If files in MO2-managed mod folders change via Bash, an external editor, or any path other than MO2 itself, MO2 may not detect them until F5. Prefer MO2-aware paths (writing through CK, writing through VS Code's configured output dir into a registered mod folder, etc.). After any external change, refresh MO2 before launching CK or the game.

### 6.5 Compile cleanly

Treat Papyrus warnings as errors during dev. A `.psc` that compiles with warnings ships warnings. Many warnings are real (unused property, mismatched cast, suspicious comparison) — fix them at authoring time.

### 6.6 Search before removal

Before removing a Papyrus function, property, magic string, or shared block, recursively search the whole active source tree for every symbol it defines or relies on. Papyrus compile failures from half-removed shared flags often surface far from the actual deletion.

### 6.7 Clean stale record references when retiring surfaces

When removing or retiring script properties, proof activators, placed references,
helper records, FormList entries, or other CK/ESP surfaces, cleanup is part of
the closeout. Sweep the live plugin, source scripts, manifests, verifier
contracts, and setup notes for stale VMAD properties, stale EditorIDs, orphaned
base records, and helper placements that would still bless or expose the
retired surface.

If the retired surface was visible in a live worldspace or cell, add a verifier
or helper check that fails if the record returns. A one-off xEdit/houseCARL
cleanup is not enough when the same stale record could be recreated by an
authoring helper or preserved by a manifest.

### 6.8 Strip debug before release

Trace messages and the debug spell are dev tools. Either remove them or gate them behind a `bDebugMode` global in MCM before any public release. A player's `Papyrus.0.log` filling with `[PDV]` traces is a defect, not a feature.

### 6.9 Keep script source pure ASCII

`.psc` source -- code and comments alike -- must be pure ASCII (every code point `<= 0x7F`). Smart punctuation (em/en dashes, curly quotes, ellipsis, arrows) and stray UTF-8 BOMs are the root cause of the mojibake the coding agent keeps finding: each is valid UTF-8 until a Windows-1252-assuming tool round-trips it into garbled lead-byte sequences. Author comments with straight quotes, `--`, `...`, and `->` instead.

Enforce before committing script work:

- `node tools/pdv_ascii_guard.mjs` -- scans the live deployed `.psc` source; exits 1 on any non-ASCII. This is the pre-commit gate.
- `node tools/pdv_ascii_guard.mjs --fix [paths]` -- auto-replaces the known offenders and strips BOMs (idempotent; unmapped characters are flagged for manual review, never silently mangled).
- Claude sessions also run a `PostToolUse` hook that blocks any `.psc` write containing non-ASCII before it can reach a handoff.

Wider docs and manifests Codex reads can be swept advisory-only -- design docs legitimately carry box-drawing, section signs, and status emoji, so this is a report, not a hard gate:

`node tools/pdv_ascii_guard.mjs --summary --ext .md,.json,.csv handoff references race-sheets`

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

The files under `archive/` are frozen source material. The inherited HOUSECARL_*.md standards came from a prior project (an MCP server for Bethesda mod analysis), while later dated intake notes preserve external lessons after their actionable rules are folded into living docs. If a question arises that this file doesn't cover, they're the next layer to consult — particularly:

- `archive/HOUSECARL_DOC_HYGIENE.md` — the full anti-pattern catalog (AP-1 through AP-7) and rationale for each rule in § 1–§ 2 above.
- `archive/HOUSECARL_AGENT_PROTOCOL.md` — the full conductor/executor pattern, PROGRESS.md format, and self-verification protocol if multi-agent work ever scales up.
- `archive/HOUSECARL_SKILL_AUTHORING.md` — source material for PDV's local Codex skills. Current skill sources live under `skills/`; keep them concise and specific to repeated PDV workflow pain.
- `archive/HOUSECARL_MCP_AUTHORING.md` — applies only if PDV ever grows a tooling MCP component. Currently out of scope.
- `archive/Skyrim_Modding_Lessons_2026-05-14.md` — external practical Skyrim/Papyrus lesson intake. Its actionable rules are folded into this standards doc, `AGENTS.md`, `PDV_MOD_SETUP.md`, `references/PAPYRUS_KNOWLEDGE_INTAKE.md`, and the PDV Papyrus/CK skill.
- `archive/Skyrim_Modding_Lessons_Full_2026-05-14.md` — expanded external lesson intake covering compile workflow, arrays, dialogue, storage backends, JContainers, debug traces, MCM OIDs, CSF, and runtime identity patterns.
- `archive/phase-order-recommendations-2026-05-20.md` — frozen branch-review analysis for why the living v3 plan adopted the reduced Pattern Proving reorder instead of the full extra-slice rewrite.

**Don't copy text from the archive into LIVING docs verbatim.** If a rule from the archive should apply to PDV, restate it scoped to PDV and cite the archive as source. Verbatim copies create the parallel-doc-drift problem § 2.1 exists to prevent.

---

*End of PDV_STANDARDS.*
