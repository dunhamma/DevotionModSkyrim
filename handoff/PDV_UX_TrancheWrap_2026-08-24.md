# PDV UX tranche wrap — 2026-08-24

**Status:** LIVING until Codex consumes sections 1 and 2, then ARCHIVE.
**Audience:** Codex (sections 1–2), owner (sections 3–5).
**Evidence bucket:** git readback for section 1; static doc/source/workbook reads for the
rest. No in-game proof in this tranche.

---

## 1. Branch and worktree hygiene (done, verified)

Local branches went from 30 to 6. Ancestry was re-verified with
`git merge-base --is-ancestor` immediately before deletion, against `main` and against the
then-current `feature/v3-big-update` tip (`4c90ee6c`), not against the stale tips recorded
earlier in the session.

**Deleted — fully merged into `main` (9):**
`claude/active-branches-reconcile-4e31b8` (d5033035), `claude/devotion-mod-handoff-fe5401`
(d5033035), `claude/devotion-mod-handoff-plan-d0c225` (d5033035),
`claude/devotion-mod-v3-phase-c-ac4bd8` (d5033035), `claude/exciting-dewdney-1c5e76`
(d5033035), `claude/mod-compat-1.5.0` (a9820f86), `claude/workplan-confirmation-203010`
(d5033035), `claude/zen-roentgen-fbc787` (d5033035), `worktree-agent-a90b906110753c70a`
(d5033035).

**Deleted — fully merged into `feature/v3-big-update` (15):**
`claude/v3-adapters-t1` (53c4d930), `t2` (2d6c43f1), `t3` (fde65d09), `t4` (04777c7a),
`t5` (39b486a9), `claude/exciting-aryabhata-0f990b` (65ca5c89),
`feature/v3-debug-extraction` (01325296), `feature/v3-post-module-integration` (188b002a),
`feature/v3-provider-seam-spec` (9e1c3a65), `feature/v3-recognition-extraction` (d8f9d88c),
`codex/v3-broad-scope-likes-fix` (8609d01d), `codex/v3-qr-bounded-ingress-fix` (6568e5e2),
`codex/v3-qr-catalog-wire-fix` (b1367b81), `codex/v3-qr-eligibility-canary-fix` (d04f4732),
`codex/v3-qr-toast-source-fix` (e026ca8d).

**Kept, and why:**
- `main`, `fix/2.0-copy-uplift` (UX), `feature/v3-big-update` (coding).
- `hotfix/1.5.0e-daedric-consent-kid` — shipped 1.5.0e; the hotfix-to-main reconciliation
  its own handoff calls for is still outstanding. Not this tranche's work.
- `claude/clever-goldstine-e63b0a` (ea3f3210) — one unmerged commit, "hash source CONTENT,
  not checkout line endings" in the felt registry. **Codex disposition needed:** this
  looks like a real fix for a line-ending-sensitive hash; it is in no other branch.
- `claude/codex-artifact-repo-source-1d6819` (931826d1) — one unmerged commit adding a
  repo-durable living source for the 2.0 rebuild dashboard. **Codex disposition needed.**

**Worktrees:** 11 to 4. Removed `.claude/worktrees/workplan-confirmation-203010`,
`.claude/worktrees/jolly-cohen-61d85d`, and the five `C:/w/pdv-*` Codex worktrees. Kept
`.claude/worktrees/v3-origin-extraction`, `.claude/worktrees/exciting-aryabhata-0f990b`
(holds the unmerged branch above), the main tree, and Codex's own `.codex/worktrees/d671`.

**Rescue, before removal.** No worktree had uncommitted tracked changes. Five of them did
hold gitignored, local-only live-ESP backup snapshots that existed nowhere else — all
newer than anything in the main archive, whose latest was `pre-sync-20260812-152316`.
Eleven snapshot directories were copied into
`generated/live-devotion-backups/`, each verified to contain its 656,418-byte
`Devotion.esp`. Provenance is recorded in
`generated/live-devotion-backups/RESCUED-FROM-WORKTREES-2026-08-24.txt`, because the
timestamp folder names cannot carry it. Nothing was deleted from the archive.

## 2. UX / V3 split policy

The split is structural already: UX on `fix/2.0-copy-uplift`, coding on
`feature/v3-big-update`. Keeping it that way:

- The UX branch touches only `handoff/`, `references/authoring/` design docs, the tracked
  workbook, and untracked workbench scratch. Never `.psc`, ESP, Prisma assets, or the
  toolchain scripts.
- Do not merge `feature/v3-big-update` into `fix/2.0-copy-uplift` mid-design. Reconcile
  only when Codex consumes an implementation packet.
- Work flows one way: approved surface plus owner wording, then an implementation packet,
  then Codex on the coding branch.

Two commits landed on the UX branch this tranche: the disposition-audit decision entry
with the continuation handoff, and the workbook durability change. The prose workbook
(`PDV_Accessible_Prose_Editing_Workbook_v2.xlsx`) is now tracked; `outputs/` was carrying
7,856 untracked files and is now ignored except for that one file. It is the single
editable authority for owner wording and had no second copy, so untracked was a
disappearance risk rather than a space saving.

## 3. Tranche design outcome

See `handoff/PDV_UX_MarkedTier_DesignBrief_2026-08-24.md`. Short version: working the two
Nord Talos "Marked" beats surfaced that the entire `Marked` surfacing rung from
architecture 10.6 has no implementation — all contextual favor leaves through one
`SendPrismaEventToast("favor", ...)` call, so a costly act and a cheap one are surfaced
identically. The recommended route is a new event name on that already-wired typed
payload, paired with a Book of Days entry, since the vanilla MessageBox cannot render the
title both drafts specify.

The brief also flags an audit finding: four `FavorMarked` rows are classified `Reconcile to
current runtime` against records that are demonstrably different moments, so the headline
"311 reconciled" is over-counted for this tier. Five owner decisions are parked in the
brief's section 8. Nothing is approved for implementation.

Both manual-review contradictions were then resolved — see
`handoff/PDV_UX_ManualReviewResolutions_2026-08-24.md`. The Argonian Sithis row is a live
copy defect rather than a missing beat: a toast and a driver record do fire, but the
phrase "crossing a Void threshold" is attached to every post-activation signal instead of
to the crossing, so it is true once and wrong thereafter — and the toast is called with an
empty context, discarding that phrase before the player ever sees it. The Khajiit row is not a contradiction at all — "the substrate does
not decay" governs the lunar metric, while the neglect spell is the separate lane-neglect
channel the same design document specifies; it needs reclassifying, not fixing.

Those two plus the Marked-tier finding converged on one shape: PDV computes state
transitions reliably and announces them inconsistently. About 19 of the audit's 45
`Consider new implementation` rows are that single missing capability rather than 19
separate features.

## 4. Backlog queue for the next tranches

Ranked, from `PDV_WordingRevisionBacklog.md`, `PDV_V2_Backlog.md`,
`PDV_DaedricRaceResponse_Backlog_2026-08-07.md`, `PDV_PrismaUXEquityAudit.md`, and the
ImmersiveUX docs. Nothing here is started.

1. **Formal commitment offer copy.** 23 of 45 offer `MESG` descriptions never name their
   deity; the per-record inventory is already complete in the wording backlog. Owner
   drafts, Codex applies and reads back. Fully scoped, high value.
2. **The two manual-review contradictions.** Small, and they unblock the audit.
3. **Long Devotion mark wording.** One owner pick among four drafted candidates.
4. **PLACEHOLDER copy sweep.** Five self-marked live placeholder surfaces: Daedric survey
   text, pact switch/severance, pact lapse, generic curse toast, generic curse Book of
   Days entry.
5. **MCM Status page redundancy.** "BROAD" appears four times and "NINE DIVINES" three
   times on one screen; the collapse direction is already sketched. Implementation is
   deferred to the MCM rebuild, but the information architecture can be designed now.
6. **Daedric race-response family.** Sixteen Princes of copy with no organic call site,
   owner-ruled backlog on 2026-08-07. Needs a trigger design and a copy bar — the same
   shape of problem as the Marked tier, and probably the same answer.
7. **Substrate-race Prisma equity.** The panel is built around a metric that is null for
   substrate races, so they read as empty rather than alive and miss the whole toast
   stream. Design living surfaces per substrate race.
8. **Draw down the remaining `Consider new implementation` rows** cluster by cluster. The
   45 rows are mostly four shapes: about 18 neglect-texture notifications (Altmer,
   Argonian, Bosmer, Imperial, Orc), 9 curse-state messages (Breton, Dunmer), 11
   standing/memory notifications (Breton druidic, Dunmer Tribunal, Imperial Concordat),
   and 7 Noted/Marked favor beats. Nord neglect presentation is the natural next cluster.
9. **Diegetic surfaces Tier B buildout.** Larger portfolio: OAR-driven rites, tints,
   auras. Spec-ready per surface, but a real scope commitment.
10. **Parked on runtime evidence.** Lowercase deity name in a Prisma toast — the
    current-source defect hypothesis is closed and gated; it needs a fresh-game recheck,
    which belongs to a runtime sitting, not a design one.

## 5. Enhancement candidates not in any backlog

Offered for discussion; none pre-approved.

1. **Threshold-anticipation cues.** Surface an "approaching" state before tier and
   threshold crossings — generalising the Argonian Sithis case. The mood teaser is the
   precedent, and its known blindness to broad worship is the thing to fix while doing it.
2. **A "why did this happen" affordance.** The driver-reason pipeline already produces
   human phrases; surfacing them in Ledger entry detail would make any piety change
   traceable by the player. The wiring exists, so this is presentation design only.
3. **Recovery beats as first-class journeys.** Curse and neglect *entries* are designed
   with care; the exits are thinner. Curse lifted, neglect repaired, and a gentle later
   re-offer after a refusal that currently goes deliberately silent.
4. **Cross-surface voice matrix.** One event often fires a toast, a Book of Days entry, and
   a Ledger row. A workbook view grouping copy IDs by triggering event would let all three
   be reviewed as one voice instead of three rows. Offline tooling only.
5. **Copy-density equity heatmap.** Regenerable from the census: rows per race per journey
   stage, to find under-served races quantitatively rather than by impression.
6. **Copy-length budget lint.** The surface catalogue already carries per-field character
   and line budgets; an offline check could flag workbook rows that overflow their
   surface. Touches no game file.
7. **First-hour experience map.** Onboarding is currently implicit across surfaces. One
   Penpot page for startup choice, first signal, first survey, first offer would make it
   reviewable as a sequence.

## 6. Penpot

The Penpot MCP server is available to Claude in this session, but the workspace plugin was
not connected, so no board was read or written. The file the owner is working in is the
`Devotion UX Workbench` at `design.penpot.app` (team `63bdc57a-…a1161a66`, file
`63bdc57a-…db2578faa`); the host is reachable over HTTPS from this machine. To hand
boards back and forth, the plugin has to be started inside that file — after which Claude
can read structure, export a board to an image, and draft additive boards from the surface
templates. Standing rule for any future sitting: probe the connection before making any
claim about a board, and never describe one from a doc.
