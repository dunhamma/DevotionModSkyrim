# PDV Session Handoff — 1.0.3 Release + Daedric/Curse Fixes (2026-07-25)

## TL;DR / status

1.0.3 is **fully implemented, verified, and packaged**. It bundles two reported bugs, a
QoL request, a whole class of Daedric record drift, three stale-audit fixes, and curse
polish. **`pdv_verify` is FAIL=0 for the first time** (started the session at 38 FAIL).

- **PR:** [dunhamma/DevotionModSkyrim#26](https://github.com/dunhamma/DevotionModSkyrim/pull/26)
  — branch `release/1.0.3` -> `main`, 4 commits, pushed.
- **Zip:** `dist/Devotion-1.0.3-20260725.zip` (sha `6E81E733…`), built by
  `pdv_package_release.mjs --version 1.0.3`; version + ANAM + clean-archive gates pass.
- **Verifier:** `node tools/pdv_verify.mjs` -> **FAIL=0** (PASS≈3560, 1 WARN = SEQ mtime
  older than ESP, benign; a few INFO).
- **RELEASE IS HELD by owner decision.** Nothing is published beyond the branch/PR. The
  owner is smoke-testing on a fresh save and will **merge PR #26 + cut the GitHub release**
  (attach the zip) themselves. Do not push a release/tag without their go-ahead.

## What shipped in 1.0.3

| Area | Change | Layer |
|---|---|---|
| Save-corruption stat drift | Added `Recover` to all 418 ValueModifier MGEFs (422/422 now). | ESP (records) |
| Redguard "Remembering" message | Reworded bare `%` -> "percent". | ESP (MESG) |
| Curse dungeon-music | Retired the persistent `PDV_MUS_CurseBed` bed + auto-heal on load; repointed onset/cure stings to relevant vanilla sounds. | Papyrus (`PDV_DiegeticDirector`) + ESP (SOUN) |
| 4K toast QoL | Resolution-scoped CSS enlargement (1080p untouched) + longer duration; cache token `pdv-5c1a137356e9d8ee`. | Prisma view assets |
| Daedric pact PRICES (18) | `ValueModifier` -> `PeakValueModifier` so max-pool cost is actually applied (were inert). | ESP (records) |
| Daedric pool BOONS (9: Sheo/Namira/Hircine) | Same inert->Peak fix (not verifier-flagged; folded in for consistency). | ESP (records) |
| Hermaeus Mora Champion boon | Both effects pointed at one Magicka MGEF; re-wired to Alteration +20 (repurposed `0713D4`) + Fortify Magicka +20 (`0716C0`). | ESP (records) |
| 16 Daedric-path quests | Removed the redundant `PDV_DaedricPathBase` VMAD attachment (concrete already `extends` base). | ESP (VMAD) |
| Curse-cure latency | `HandleCurseStateTransition` now calls `SyncFirstTierRaceRewardRuntime()` after the race handlers -> penalties lift immediately on cure, not next dawn. | Papyrus (manager) |
| Redguard vampire-cure message | `PDV_Msg_...VampireCured_TuwhaccaReEntry` (`0714E9`) + `.psc` fallback now state the protection returns on death-duty re-entry. | ESP (MESG) + Papyrus |
| Tooling: 3 stale audits | `pdv_pantheon_record_readback` + `_presentation_readback` resolve VMAD properties by NAME (tail window) not drifted index; `pdv_active_effect_naming_audit` exempts the Daedric boon family. | tools/*.mjs |

### PR #26 commits (newest last)
- `f7609cf` release: 1.0.3 (Recover flag + curse-music + toast QoL + docs)
- `15eda25` release: fold in Daedric pact fixes (prices/boons, Mora, VMAD) — changelog
- `c87b356` chore(tools): fix 3 stale verifier audits -> pdv_verify FAIL=0
- `3e8eb2b` fix(curse): instant restore on cure + clearer Redguard vampire-cure message

### GitHub issues filed
[#23](https://github.com/dunhamma/DevotionModSkyrim/issues/23) (Recover),
[#24](https://github.com/dunhamma/DevotionModSkyrim/issues/24) (curse music),
[#25](https://github.com/dunhamma/DevotionModSkyrim/issues/25) (toast QoL).

## Key technical facts (read before touching the ESP or the release)

- **Dev/packaging instance:** Anvil MO2 (`D:\Wabbajack\modlists\Anvil`, profile
  **"Devotion Dev"**). houseCARL is currently pointed there. It was on the **ARR** list
  (`D:\Wabbajack\modlists\ARR`) for reporter-parity reads, then re-pointed to Anvil for all
  authoring (`housecarl_set_mo2_instance`).
- **The live dev `Devotion.esp` is NOT git-tracked** (only an old `generated/live-devotion-snapshot/…`
  copy is). So ESP record fixes have **no git diff** — they live in the live ESP and ship via
  the zip. Git PRs carry only Papyrus (`live-source/`), Prisma (`native/…/PrismaUI/`), tools, docs.
  (Memory: `dev-esp-not-git-tracked-ships-in-zip`.)
- **Release gate = version + ANAM + clean-archive** (`pdv_package_release.mjs`), NOT full
  `pdv_verify`. Verify FAILs never block packaging, but this session proved they are often REAL
  drift — investigate each, don't assume stale. (Memory: `release-gates-not-full-verify`.)
- **MGEF Archetype is a polymorphic discriminated union** — you can't `Set Archetype.Type`
  (P-DISC error). Use `housecarl_bulk_apply` compose:
  `{type:"MagicEffectPeakValueModArchetype", fields:{ActorValue:"…"}}` on the `Archetype` field.
- **Two source trees** (live `D:\…\Scripts\Source` + git `live-source\Scripts\Source`) — kept
  byte-identical this session. **`PDV_Origin.psc` drifts (live ahead of git)** — do not clobber it;
  `sync-devotion-to-live.ps1` does NOT copy it.
- **ESP backups** from this session are in the session scratchpad (will not persist):
  `Devotion.esp.1.0.2.bak` (pristine 1.0.2), `.1.0.3-edited.bak`, `.pre-daedric-1.0.3.bak`. If a
  clean 1.0.2 ESP is needed later, pull it from the shipped `dist/Devotion-1.0.2-*.zip`.

## Open items / next steps

1. **Owner:** merge PR #26, cut the GitHub release, attach `Devotion-1.0.3-20260725.zip`
   (prerelease per the project's tester-bundle pattern). Held for their smoke-test.
2. **Pre-1.0.3 saves** carry baked stat-drift residue that 1.0.3 prevents going forward but does
   NOT retroactively heal (Recover only stops future drift). Cure = documented **manual console
   procedure** in `CHANGELOG.md` (`player.getav <AV>` -> `player.modav <AV> <residue>`). Owner chose
   **prevention-only** — no scripted auto-repair (residue is not computable exactly from stored data;
   PDV's `…Count` keys are piety-event counters, not AV magnitudes).
3. **Backlog entries left UNCOMMITTED** in the working tree: `references/authoring/PDV_V2_Backlog.md`
   §8 (ValueModifier convention-cleanup investigation) + §9 (diegetic-cue follow-ups). Left uncommitted
   because the file already carried an unrelated **in-progress Orc Trinimac** backlog edit (not this
   session's) — do not sweep it. Owner to commit the backlog with their Trinimac work.
4. **Other pre-existing uncommitted working-tree changes are NOT this session's** and were left
   untouched: `.gitignore`, `PDV_1_0_FreshnessStamps.json`, `PDV_BetaContract.csv`, a
   `PDV_AncestralSpine_ParityAudit` archive move. Codex is the git user — verify `+N/-0` and stage
   only intended files.

## Backlog / deferred (not in 1.0.3)

- **ValueModifier convention cleanup** (backlog §8): the 418 neglect/penalty effects use negative
  magnitude + no `Detrimental` (cosmetic red-debuff display only). Deferred — cure/dispel + resist
  interactions vs Requiem/Authoria, ~400+ spell edits. Owner requested a hygiene investigation.
- **Diegetic-cue redesign** (backlog §9): short relevant stings for all tones; the persistent
  `PDV_Abil_Shader_Dread` screen shader on the same curse-onset path (review); stale MCM
  "Diegetic surfaces (D1) — default off" help text; orphaned `PDV_MUS_CurseBed` record.
- **Redguard VAMPIRE cure intentionally holds** the −3 ResistMagic until a Tu'whacca sect
  re-entry act (by design, now messaged clearly). Not a bug — do not "fix" it.

## Investigations run this session (all read-only; findings applied)

- **35 Daedric verifier FAILs** — REAL drift (a 2026-07-13 hardening pass added checks + wrote
  "fixed" in AGENTS.md but the fixes never reached the shipped ESP). Fixed this session.
- **3 remaining FAILs** — STALE audits (drifted absolute VMAD indices; over-broad naming rule on
  Daedric boons). Records were correct; audits fixed.
- **Redguard lycanthropy magic-resist loss** — it's the `Recover` bug: lycanthropy pins the Redguard
  "ancestor-distance neglected" flag (`CyclePressure`), which adds the −3 ResistMagic neglect; pre-1.0.3
  drift made it look like "all" resist. Same class hits **Dunmer (Magicka), Orc (DamageResist),
  Argonian (HealRate)** — all now guarded by `Recover`. Imperial/Altmer/Nord curses are piety/favor
  gates (different, self-restoring class). 1.0.3 prevents it; residue = manual cure; latency + message
  polish added.

## Verification state

- Static/readback/gate proof complete: houseCARL readbacks, 3 Prisma audits green, `pdv_compile`
  0/0 (manager + director), `pdv_verify` FAIL=0, package gates pass.
- **In-game smoke evidence is now partially captured.** The owner has confirmed the
  disfavor repeat-cycle direction/restoration, curse application/restoration, repaired
  Daedric price scaling across Azura and Mephala, the Hermaeus Mora Champion two-effect
  combination, the enlarged/longer 4K toast presentation, and MCM page-routing sanity.
  The DrHeisen-port stat maintenance controls are deferred, not failed, until an external
  tester has a suitable damaged-stat state and disposable save. Remaining owner packet work
  begins at shrine credit, followed by ordinary piety accrual, optional bard restart, and
  the two classification probes; do not describe the entire packet as closed yet.

## Watch-outs

- The 3 audit `.mjs` got a git LF->CRLF warning — harmless for tool scripts (no byte-hashed gate,
  unlike the Prisma cache-key files which MUST stay LF).
- Prisma cache-key gate hashes raw bytes of `app.js`+`styles.css`; any edit needs both `index.html`
  `?v=` tokens bumped to `pdv-<sha256(app⧺style)[:16]>`, LF-only.
- houseCARL in-place ESP edits have NO undo — back up `Devotion.esp` before a bulk pass.
