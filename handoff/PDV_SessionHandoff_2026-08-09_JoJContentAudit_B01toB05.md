# Session handoff -- 2026-08-09

Class: ARCHIVE (a record of one session; not a status doc)
Session: JoJ Phase 1 content audit, batches B01-B05, plus the tooling that made them
possible. Branch `feat/joj-phase1-content-audit`, head `7f5f4568`.

## Where this stands

**28 of 37 mods complete. B06 (8 follower mods) is all that remains; B07 is deferred.**

```
B01 2/2   B02 5/5   B03 4/4   B04 11/11   B05 6/6   B06 0/8   B07 0/1
verdicts: SILENT 5, APPROVED 23, UNREVIEWED 9
next: Sachil (B06) blocked at stage_digested
```

The hub went 46 -> **69 options**, award rows 534 -> **2183**, source CSVs 44 -> **67**.
Working tree is clean and **all eight gates exit 0** as of handoff: `pdv_qrm_lint`,
`pdv_joj_tagged_rows_check`, `pdv_external_support_inventory --check` and `--coverage`,
`pdv_matrix_runtime_preflight --name-resolution-only`, `pdv_quest_patch_fomod_validate`,
`pdv_quest_tranche_merge --check`, `pdv_player_facing_copy_gate`.

**Nothing is released.** `v1.5.0-test1` still carries the old asset. The FOMOD rebuild is
owed once the content work is where the owner wants it.

## Start here

```bash
node tools/pdv_joj_content_checkpoint.mjs --check
```

That names the next blocked mod and what it is blocked at. It is the ONLY thing a fresh
session needs to read before continuing -- not this document, not the plan. Every state
transition is a column in
`references/vanilla-gameplay/compatibility/PDV_JoJ_ContentCheckpoint.csv`; nothing lives only
in a conversation.

`--init` refuses to overwrite an existing checkpoint (exit 2). That is deliberate: a resumed
session that re-inits loses the run, and the loss looks exactly like never having started.

## The chain, per mod

Proven across 28 mods. Nothing new needs building for B06.

```bash
node tools/pdv_joj_stage_digest.mjs --batch B06          # digest to disk, one line of stdout
# judge -> generated/joj-rows/<Mod>.tagged.csv            (deityless, 9 columns)
node tools/pdv_joj_tagged_rows_check.mjs                  # gate the judge BEFORE cross-gen
node tools/pdv_quest_cross_gen.mjs --source generated/joj-rows/<Mod>.tagged.csv --output-prefix B06_<Mod>
# review anomalies, promote -> references/authoring/patches/PDV_QRM_<Mod>.csv
node tools/pdv_qrm_lint.mjs --csv references/authoring/patches/PDV_QRM_<Mod>.csv
node tools/pdv_joj_stage_digest.mjs --verify-rows references/authoring/patches/PDV_QRM_<Mod>.csv
node tools/pdv_quest_matrix_compile.mjs --matrix <csv> --output dist/.../Channels/PDV_QRM_<Mod>.json
# manifest entry, then:
node tools/pdv_quest_patch_fomod_generate.mjs --write     # then bare, to prove idempotence
node tools/pdv_quest_patch_fomod_validate.mjs
```

B06 is `Sachil` 45, `ValSerano` 62, `RedcapTheRiekling` 40, `KhajiitWillFollow` 36, `Gore` 25,
`Taliesin` 17, `MerlinTheCorgi` 2, `Hoth` 1 -- 228 quests, none digested yet. The last three
are cheaper judged inline than delegated to a subagent.

Judging briefs are in this session's transcript; the three corrections they MUST carry are
below under "things that cost time".

## Rulings the owner made, do not relitigate

- **Kaidan is two options**, base plus Immersive Features. `Kaidan - Immersive Features.esp`
  declares `0Kaidan.esp` as a MASTER, so it extends rather than replaces.
- **Marriage yes, romance as positional rows, NSFW never.** `KaidanNSFWQuest` has 0 stages and
  0 objectives -- there is no hook, on mechanics not content. `K04` romance shipped as exactly
  TWO positional rows (s50, s100) whose citations say outright that they cite a stage position
  and not evidence.
- **The Hist is only for Argonians.** This settled 14 rows that had been cut or held on a
  misreading. Its `protect_the_weak` is NOT filtered to Argonian victims -- the Hist is NATIVE
  to Argonian and FOREIGN to everyone else, so it is only ever read by an Argonian player.
- **B07 (Interesting NPCs) is deferred to its own program.** 488 quests in one mod, content
  split UNMEASURED. Its silence-ledger entry must say "deferred, pending survey" -- it was
  never assessed.
- **Calibration is LOCKED** (`AGENTS.md:1623`): no per-quest cap on how many deities react.
  Pacing is tuned via milestone VALUE. A stage with >12 reactors is a prompt to re-examine the
  TAG, never licence to trim gods.

## Things that would have cost a day to rediscover

**The digest helper was broken and could not have been used.** `probeQuestDetail` passed
`depth: 1`, where houseCARL answers `Stages = [list: 0 item(s)]` -- not the stages, and not
even a correct count. Anything built on it would have read every quest as empty and called
that a finding. **depth 5** is the first that returns `LogEntries[0].Entry`. Also:
`CompleteQuest` sits on the LOG ENTRY, not the stage.

**Two FormID notations, and they are reversed.** houseCARL enumerates `HEX:PLUGIN`; the matrix
CSVs and the compiler want `PLUGIN:HEX`. This cost a whole judging batch -- the digest printed
houseCARL's form and the brief said "copy verbatim". The digest heading now prints the
authoring form, derived from the formid so an override still names its defining master.

**A legal tag prefix with an illegal Prince slug is the worst failure available.** Part A
defines `serve_a_daedra:<prince>`, so ANY suffix passed the check -- and a wrong one matches no
profile, so it fans out to nobody, silently. A judging pass emitted `clavicus_vile` (the slug
is `clavicus`) and `umbra` (not a Prince). `pdv_qrm_lint` and `pdv_joj_tagged_rows_check` now
validate the slug against the **declared roster in Part B-2** -- 16 slugs, one per Prince. Read
that table rather than copying a list into a judging brief; it is the authority and it moved
once already.

**The hand-written file was the broken one.** `pdv_joj_tagged_rows_check` caught unquoted
commas in a file I typed, shifting every later column -- an act tag reading "out of pride", a
formid holding a whole citation. The subagent files were clean. Do not gate only what an agent
produces.

**"Is it an override" is the wrong question; "does it ADD the stage" is the right one.**
`ResolveQuestReactionCellFile` matches per CELL, core first then each channel, so core owning
`DB01 s200` does not shadow a channel owning `DB01 s21`. A stage vanilla already has belongs to
core and a channel row for it is dead weight; a stage the mod ADDS belongs in the mod's channel
on the vanilla FormID. The Choice Is Yours is SILENT on exactly this test (16 overrides,
vanilla's stages unchanged); Innocence Lost QE is the opposite and adds a lawful path where
Grelod is jailed instead of murdered.

**cross_gen DROPS a deity whose profile both approves and disapproves a cell.** It refuses to
guess -- correct -- but the reaction then goes silent and nothing says so. Five had to be
hand-resolved in B03. Check `_Conflicts.csv` every time.

**A tag that produced NO candidates is invisible to an anomaly review**, because the review is
built from the candidates. `destroy_reject_daedra:vaermina` looked dead and was merely
subsumed -- its two carriers were already credited on that stage via other tags.

**Coverage floor is 60% of a MOVING median.** It has now named five thin gods as the matrix
grew -- Sanguine, Peryite, Namira, Clavicus Vile, Sheogorath, all waived as narrow by design
with their profile sizes as the reason. Hircine was waived as a CONTENT gap instead, and a
separate session cleared it by rowing `embrace_lycanthropy` -- which is what a waiver written
as a to-do is supposed to invite.

## Open items

**Nine NEEDS-TAG proposals** are parked with empty `act_tags`, so cross-gen yields nothing and
they do not ship. They are a vocabulary-gap list for the owner, not decisions:

| mod | quest | proposed |
|---|---|---|
| Lucien | `JRLucienDragon` s11 | `rebuke_harden_companion` |
| Lucien | `JRLucienElderScroll` s20 | `refuse_forbidden_knowledge` |
| Lucien | `JRLucienPaarthurnax` s10 | `reject_mercy_declare_kill` |
| Lucien | `JRLucienPersonal1` s800 | `destroy_unnamed_daedric_entity` |
| Remiel | `HLIOMQ1` s110 | `traffic_contraband` |
| Remiel | `HLIORPLock` s80 | `decline_aid_crime` |
| MoonAndStar | `MASAlbertDialog` s30 | kindness to a child for its own sake |
| ThereIsNoUmbra3 | `0_FloatingSwordQuest03` s300 | `renounce_dangerous_power` |
| ThievesGuildForGoodGuys | `TG00` s210 | `refuse_criminal_faction` |

**Daedric slug drift -- CLOSED.** Landed as PR #68 (`9e6b27fa`) while this handoff was being
written; this branch is rebased onto it and all seven gates re-verified green afterwards,
including every B05 channel.

It went further than the task asked, and the extra work is worth knowing about:

- The slug roster is now **DECLARED** in a "Canonical Prince slugs" table in Part B-2 and read
  only from there. `daedricSlugs()` used to harvest from the shipped CSVs as well, which was my
  design and was wrong for the reason the PR states plainly: a harvest cannot rot away from the
  data, but it also cannot DISAGREE with it, which is the entire job. A typo became "known" the
  moment it was committed. That is how `dagon` and `mehrunesdagon` both passed a green lint
  while naming the same Prince.
- The parser is scoped to the table's own rows, because the prose around it names the slugs
  that were REJECTED and a doc-wide scrape would re-legalise every one.
- It caught something this session missed entirely: `PartD_ThinGodFaucets` was being skipped
  wholesale for having no `outcome_stage`, but its `act_tag` carries a Prince slug into the
  same anti-farm cap key the quest rows use -- so `serve_a_daedra:molag_bal` was sitting beside
  `serve_a_daedra:molagbal` as two buckets for one act. Slugs are now checked there;
  everything else stays skipped.

`serve_a_daedra:azura(defied)` is fixed and its waiver removed -- waivers are down to 34.

**FOMOD ESP placement.** The five ESP patches land wherever MO2 appends them -- in ARR 2.5 that
is under the "Authoria - Outputs" separator, which reads as regenerated tool output. All five
are ESL-flagged and master the mod they patch, so bottom placement is functionally correct and
a FOMOD cannot set load order anyway. The fix is documentation: state the intended slot in the
README and the packaging authority.

**`contestedRecordCount === 33` is pinned, not verified** in `pdv_package_release.mjs`. All 33
were enumerated on 2026-08-09 and the number is right today, but the gate cannot tell a correct
33 from a coincidental one. Recorded in the release proof's `gateCaveat`; no issue filed yet.

**`PDV_CompatInvestigation_Findings.md` (22) and `PDV_Phase21_ARR_ExtensionMap.md` (99)** carry
pre-existing non-ASCII. Untouched deliberately -- the standing rule is not to mass-`--fix` docs.

## Process notes worth keeping

**Read a gate's exit code, and never through a pipe.** Twice this session a FAIL was lost to
`| tail` or a `;` chain and a commit went through on a red check. Both times the content was
fine; both times that was luck. `${PIPESTATUS[0]}` or a plain `if` -- not `&&` after a pipe.

**Writing Windows path separators through a shell heredoc into JSON failed three times** --
once to no separator at all, once to a lone backslash that `JSON.parse` rejects. Build it with
`String.fromCharCode(92)` in a written `.mjs` file instead of escaping through bash.

**Verify a subagent's output; do not relay it.** Every judging pass was gated before promotion,
and two needed correction rounds. The receipts are honest but they are not evidence.
