# PDV VMAD Property Audit -- 2026-08-06

**Class 1, hand-authored authority** (`PDV_STANDARDS.md` section 5.3): no tool
generates this file, so it is committed. The tool's own output goes to stdout
only (`--json`), so there is no regenerable report to gitignore. Authority for
any status claim here is a fresh `tools/pdv_vmad_audit.mjs` run, not this
rendering.

Read-only throughout. Nothing was written to the ESP; no `.psc` was edited.

---

## Verdict

A first pass of this sweep produced six findings, two of them billed CRITICAL and
HIGH. **Four of the six were then disproven** by direct investigation against live
source, the live ESP, and this project's own verifier -- including both headline
items. One of them was a *repeat* of a mistake already made and corrected in July
2026.

The durable value of this document is therefore **the disproof record in section 2**,
not a bug list. Two independent sweeps have now reported the Altmer spine trio as a
defect; without a written disproof a third will.

The genuinely useful findings in section 3 came mostly from the *investigation*,
not from the original sweep.

| Read | Value |
|---|---|
| houseCARL instance | `D:\Wabbajack\modlists\Anvil` |
| MO2 profile | `Devotion Dev` (`Devotion.esp` confirmed ACTIVE before the run) |
| Papyrus source | `D:\Wabbajack\modlists\Anvil\mods\Devotion\Scripts\Source` -- 100 `.psc`, 100 script classes |
| Records enumerated | 184 |
| Script attachments analysed | 191 (includes the manager's alias-attached `PDV_PlayerEvents`) |
| Hypotheses -> waived -> confirmed | 541 -> 495 -> 46 |
| Reported after deduplication | 31 |
| Dropped on independent re-read | 0 |
| Exit code | 1 (findings outstanding) |

Every enumerated record was accounted for; the tool aborts loudly on any
enumerated-vs-analysed mismatch. Every reported finding was re-read individually
against the live plugin after the bulk pass -- a script-derived finding is a
hypothesis, the direct read is the evidence.

> **Snapshot caveat.** The dev ESP is edited live. An earlier run in the same
> session enumerated 183 records; this one enumerated 184. Treat every count here
> as a snapshot of 2026-08-06 and re-run rather than quoting these numbers later
> (`PDV_STANDARDS` section 4).

---

## 1. Method, and the trap that produced the false findings

The tool enumerates every `VirtualMachineAdapter`-carrying record in one
`housecarl_cross_plugin_query`, reads their VMAD property bindings in batches, and
compares them against property declarations parsed from `.psc` source. Three
detectors:

- **A. Sibling outlier** -- a record missing a property the majority of its family
  carries. This is the Syrabane shape.
- **B. Declared-but-absent**, object-typed only.
- **C. Present-but-null** -- a bound entry whose `Object` is `(null link)`.

Scalar absence is deliberately *not* a detector-B finding: Papyrus applies the
script default, and leaving `DELTA_*` tuning scalars out of a VMAD is the intended
pattern. Scalars are a signal only through detector A.

**The trap:** the first pass parsed declarations from the repo's
`live-source/Scripts/Source` mirror. That mirror lags the MO2 live tree -- it has
97 `.psc` against the live tree's 100, and the three extras
(`PDV_AltmerPracticeFocus.psc`, `PDV_KhajiitAzurahPortentEffect.psc`,
`PDV_KhajiitBaanDarRescueEffect.psc`) are real in-flight work that is not on
`origin/main` at all. Auditing the mirror invented a phantom "script with no
source" gap. Per `AGENTS.md` (SHIPPED-VS-REPO SOURCE DRIFT) and `PDV_MOD_SETUP.md`
(Repo-source drift), **the MO2 live tree is authoritative**; the mirror is a
mirror. The tool now reads the live tree by default, and *warns* whenever the two
diverge instead of silently absorbing the difference.

---

## 2. Disproven -- do not re-report these

Each of the following looks like a defect from a VMAD readback alone. Each is
correct. If a future sweep surfaces one of these shapes, stop here.

### 2.1 The 16 Daedric path quests carry no `Stance_*`. This is correct.

**Why it looks wrong:** all 33 `PDV_Deity_*` quests carry ten `Stance_<Race>`
properties; all 16 `PDV_DaedricPath_*` quests carry none. `PDV_DeityBase`'s source
default is `1` (`STANCE_FOREIGN`), so `IsRaceNativeForPlayer()` would return false
and `ScoreFromTable` would early-out at 0.0.

**Why it is correct:** `ScoreFromTable` is never called on a path quest. The
generic faucet iterates `PDV_FLST_AllDeities` only (`PDV_ActionRouter.psc:447-469`,
`PDV_EventBus.psc:1572-1578`); that FormList is `017E47:Devotion.esp` and contains
33 items, all `PDV_Deity_*`, zero paths. Princes score through a separate lane
(`RouteActionToOpenPaths` -> `ScorePrinceAction`, `PDV_DaedricPathBase.psc:234-247`)
with its own `PDV.PLD.*` namespace and no stance gate. The lane's per-race model is
`StateByRace` / `StigmaModByRace` / `ExitDifficultyByRace` (7-value
`DAEDRIC_STATE_*`), all three present and `Edited` at length 10 on every path,
authored from `references/authoring/PDV_DaedricPrinceRecordContracts.json`. No
`PDV_DaedricPath*.psc` references `Stance_*` at all.

**The proposed "fix" was the forbidden change.** `tools/pdv_verify.mjs:2016` calls
`checkForbiddenFormListMembers("PDV_FLST_AllDeities", daedricPathEdids)` -- adding a
path to `AllDeities` fails the build by design.

### 2.2 The manager's three `PDV_Bless_Altmer_Spine_*` properties are unbound. This is correct.

**This is the second time this has been reported as a bug.** The first was
corrected in `references/authoring/PDV_HO_1.0.4_Scope_DrHeisenPatch_2026-07-25.md:170-197`,
which contains a "Why I got it wrong" section about these exact three records and
the lesson: *for substrate-backed rewards, check the substrate record's VMAD before
concluding anything is unwired.*

**Why it looks wrong:** `PDV__ManagerQuest.psc:176-178` declares them and
lines 17269-17271 call `SyncRaceRewardSpell` on them.

**Why it is correct:** those calls sit 242 lines inside `StripAllPdvSpells`
(`:17221-17463`), a flat teardown list where all ~240 calls pass
`shouldBeActive=False`, reached only from `PrepareForUninstall` and
`RunAuthoriaActorValueRepair`. The live grant lane is
`PDV_Substrate_AltmerAncestor` (`0715AC:Devotion.esp`), which binds
`Substrate_Always/Mid/High` to `0715A7/0715A9/0715AB`, all `Edited`.
`tools/pdv_verify.mjs:6697-6699` asserts exactly that. Binding the manager copies
would create a second owner for a substrate-owned record -- the anti-pattern
`tools/pdv_reward_runtime_order_lint.mjs:398-403` exists to prevent. Breton,
Imperial, Nord and Dunmer carry no manager spine properties at all, and their
spines work.

### 2.3 `Boon_Seeker` / `Boon_Devoted` / `Boon_Champion` unbound on 30 deity quests. This is correct.

Retired-compatibility records, deliberately never granted: a patron's blessing
begins at Devoted and there is no patron Seeker tier. The SPEL records are kept so
old saves do not break.

Authorities: `PDV_Architecture_v3.md` ADR-0005 ("focused T1 records remain
save-compatible artifacts but are never granted"); the enforcement comment at
`PDV_DeityBase.psc:410`; and the owner ruling of 2026-07-14 recorded at
`references/authoring/PDV_RaceGuide_NexusFinalPass_2026-07-14.md:91-95`, which says
verbatim: **"A future audit that flags these as 'unreachable, wire them' is
wrong."** See also `PDV_PlayerStateBugs_2026-07-14.md:148` and
`handoff/PDV_CleanupDebt_Handoff_2026-06-17.md:48-58`.

**Important scope limit:** this applies to the Aedric thin shells only.
`PDV_DaedricPathBase` overrides `SyncPatronBoonsToTier` and grants `Boon_*` for
real (`PDV_DaedricPathBase.psc:115-153`), so all 16 Prince paths do bind them and
must keep being audited. The waiver carries an explicit
`excludeScriptPrefixes: ["PDV_DaedricPath"]` for this reason.

### 2.4 Four Daedric paths omit a `Msg_Response_<Race>`. This is correct for Dunmer and Orc.

`Msg_Response_<Race>` is the "you consorted with a Daedra" reaction. It is
deliberately absent where the race worships that Prince natively through the paired
`PDV_Deity_*` quest, which owns that relationship instead. Every omission maps to a
`Stance_<Race> = 0` (`STANCE_NATIVE`) on the paired deity, confirmed by live
readback on 2026-08-06:

| Path quest | Omits | Paired deity quest | Stance |
|---|---|---|---|
| `PDV_DaedricPath_Azura` `071280` | `Msg_Response_Dunmer` | `PDV_Deity_Azura` `071078` (`DeityName="Azurah"`) | `Stance_Dunmer=0` |
| `PDV_DaedricPath_Boethiah` `07125F` | `Msg_Response_Dunmer` | `PDV_Deity_Boethiah` `071149` | `Stance_Dunmer=0` |
| `PDV_DaedricPath_Mephala` `07123E` | `Msg_Response_Dunmer` | `PDV_Deity_Mephala` `07114A` | `Stance_Dunmer=0` |
| `PDV_DaedricPath_Malacath` `071303` | `Msg_Response_Orc` | `PDV_Deity_Malacath` `071126` | `Stance_Orc=0` |

The Khajiit axis is **not** settled and is reported as an open item -- see 3.5.

### 2.5 `PDV_MISC_AltmerPracticeFocus` attaches a script with no source. False positive.

`PDV_AltmerPracticeFocus.psc` exists in the MO2 live tree with a compiled `.pex`.
It is absent from `origin/main` because it is in-flight work. Artifact of the
mirror-vs-live-tree trap described in section 1; the tool no longer produces it.

---

## 3. Confirmed open items

31 findings across 17 groups, ranked by blast radius. None have been fixed --
this PR makes no ESP writes.

### 3.1 Unbound arrays dereferenced without a null guard (17 findings) -- highest value

Papyrus errors when `.Length` is read on an unset (None) array, logs it, and yields
0, so the guarded branch never runs. Unlike the object properties elsewhere in this
report, **these call sites have no `if` guard on the array itself** -- the guard is
on the index:

| Property | Type | Records | Unguarded dereference |
|---|---|---|---|
| `ExtremeStateIndexes` | `Int[]` | all 5 `PDV_RepTrack_*` (`0499C0`-`0499C4`) | `PDV_ReputationTrack.psc:142,163,184` |
| `ThresholdValues` | `Int[]` | 3 (`0499C2`, `0499C3`, `0499C4`) | `PDV_ReputationTrack.psc:260` |
| `ThresholdLabels` | `String[]` | 3 (same three) | `PDV_ReputationTrack.psc:76` |
| `StateLabels` | `String[]` | 4 (`0499C7`, `0499C8`, `0499CA`, `0499CB`) | `PDV_StateTrack.psc:92` |

Effect: extreme-state detection can never match on any reputation track, and
label lookups on the affected tracks fall through to their fallback while logging
an error each call. This is a plausible contributor to the known
"ReputationTrack label lags raw value" behaviour and is worth checking there
first. Note `ExtremeStateIndexes` is absent on *all five* tracks, so this is not a
per-record oversight but an unfinished wiring pass.

Needs an owner decision on intended values before anything is authored.

### 3.2 `StateGlobal` unbound on 4 `PDV_StateTrack` quests (4 findings)

`07051C` `PDV_State_NordPantheonBaseline`, `070FF6` `PDV_State_AltmerCrisis`,
`071004` `PDV_State_ArgonianHistPosture`, `07150D` `PDV_State_KhajiitLunarPosture`.

Every Papyrus use is null-guarded and falls back to StorageUtil, so script-side
state tracking is unaffected. The gap is scoped to Creation Kit **Conditions**
reading the mirror global directly, per the project's "mirror globals exist only
for CK Condition reads" rule.

Three need a new GLOB authored (none exists by either naming convention). The
fourth is a **design call**: `PDV_State_AltmerCrisis` (`070FF6`) and
`PDV_StateTrack_AltmerCrisis` (`0499CB`) both carry `TrackName="AltmerCrisis"`, and
`PDV_GLO_AltmerCrisis` (`0499D7`) is already bound to the latter. Two tracks, one
name -- either one supersedes the other or they are competing for one global.

Two naming generations exist: gen-1 `PDV_GLO_<Track>` (the `0499Cx` block), gen-2
`PDV_GLO_State_<Track>` (`PDV_State_BretonDruidicFork`, GLOB FormID = quest - 1).

### 3.3 Hircine and Molag have no stigma notification messages (6 findings)

`04C8AC` `PDV_DaedricPath_Hircine` and `0712E4` `PDV_DaedricPath_Molag` are the
only two of sixteen Princes with no `Notif_Stigma_Suspected/Known/Notorious`
binding, yet both call `ShowIfPresent(Notif_Stigma_*)` from their own stigma flow
(`PDV_DaedricPath_Hircine.psc:107-109`, `PDV_DaedricPath_Molag.psc:83-85`).
`ShowIfPresent` returns `-1` on None, so the notification silently does not show.

All six MESG records are **absent** -- this is author-then-bind, not bind-only.
The other 14 Princes carry 42 messages following the convention
`PDV_Notif_Daedric_<Prince>_Stigma_<Suspected|Known|Notorious>`. Their stigma
globals already exist (`PDV_GLO_Daedric_Hircine_Stigma` `071434`,
`PDV_GLO_Daedric_Molag_Stigma` `0712E5`), so only the MESG side is missing.

Stigma still accrues correctly; only the player-facing notification is lost.

### 3.4 One T3 effect surfaces nothing (5 findings)

`0711C4` `PDV_MGEF_Nord_Shor_T3_HealRateMult` is missing `NotificationText`,
`PrismaTitle`, `PrismaText`, `PrismaSymbol` and `PrismaTone`, which 11 of its 12
siblings carry. The daily low-health save will fire without any notification or
Prisma beat. Genuine sibling outlier -- the Syrabane shape, on a presentation
surface.

### 3.5 Open design question: `Msg_Response_Khajiit` on Azura (1 finding)

`071280` `PDV_DaedricPath_Azura` omits it. Under the native-pair rule of 2.4 this
would be waived -- `PDV_Deity_Azura` carries `Stance_Khajiit=0`. But
`PDV_Deity_Boethiah` and `PDV_Deity_Mephala` are **also** `Stance_Khajiit=0` and
their paths **do** carry `Msg_Response_Khajiit`. So the rule is 100% consistent on
Dunmer and Orc and inconsistent only here: either Azura is a gap, or Boethiah's and
Mephala's Khajiit responses are dead records. Azurah is a major Khajiiti deity,
which may warrant treatment different from the other two.

Deliberately left un-waived pending an owner ruling, and recorded as such in
`PDV_VMAD_AuditWaivers.json` under `deliberatelyNotWaived`.

---

## 4. Found during investigation, outside this audit's scope

These are not VMAD findings; they surfaced while disproving the ones above and are
tracked as separate issues.

1. **QuestReactionMatrix key drift.** In `PDV_QuestReactionMatrix.json`, Namira and
   Sanguine are keyed `"Namira / Namiira"` and `"Sanguine / Sangiin"` while cells
   reference them bare. `GetQuestReactionStance` (`PDV__ManagerQuest.psc:3160-3177`)
   therefore falls through to `GetStanceForPlayer()` and resolves `STANCE_FOREIGN`
   instead of the `TABOO` both their `stateByRace` and the slash-keyed rows specify,
   for all ten races. Affects the day/weekly tally, driver ring, and
   TABOO-vs-stigma routing; **not** path tier progression.
2. **Uninstall leaves substrate boons on the player.** `PrepareForUninstall`
   (`PDV__ManagerQuest.psc:17190-17214`) calls
   `RunAuthoriaActorValueRepair(True, False)`; with `resyncAfterwards=False`,
   `SyncFirstTierRaceRewardRuntime` never runs, so `ClearSubstrateBoons` is never
   reached. Affects every substrate race. Related: the claim at
   `PDV_HO_1.0.4_Scope_DrHeisenPatch_2026-07-25.md:191-192` that the substrate
   clears itself on uninstall is **incorrect** and should be amended.
3. **Runtime-order lint blind spot.** 7 of 10 `PDV_*RewardRecords.spec.json` files
   lack a `substrateBoons` block, so `pdv_reward_runtime_order_lint.mjs` cannot
   enforce substrate ownership for those families; it also never parses
   `StripAllPdvSpells`. This is why the 2.2 class is invisible to existing tooling.
4. **Stale pinned houseCARL binary.** `tools/lib/pdv_housecarl_stdio.mjs` pins
   `DEFAULT_EXE` to a build that predates the `exists` / `missing` query
   predicates; it answers `unrecognized operator 'exists'`. The configured MCP
   server at `C:\Users\Admin\.claude\skills\housecarl\server\housecarl-mcp.exe`
   supports them. Every gate script on that shared harness carries the same risk.
   Worked around here with `PDV_HOUSECARL_EXE`; not fixed, as editing shared
   toolchain scripts is out of scope for this change.

---

## 5. Running the audit

```bash
PDV_HOUSECARL_EXE="C:\Users\Admin\.claude\skills\housecarl\server\housecarl-mcp.exe" node tools/pdv_vmad_audit.mjs
```

`--json` emits the same document machine-readably on stdout.
`PDV_DEVOTION_SOURCE_DIR` overrides the source tree.

**The verdict is the exit code, never a grepped field.** Exit 1 means at least one
un-waived finding survived independent re-read. It exits 1 today, by design, while
section 3 is open.

### Waivers

`references/authoring/PDV_VMAD_AuditWaivers.json` holds absences that are
architecturally correct. It suppressed 495 of 541 hypotheses in this run -- without
it the report is unreadable and the real findings are buried.

A waiver is a claim that needs evidence, not a mute button: every entry cites the
readback or verifier line that proves it, and is deleted the moment that evidence
stops holding. `excludeScriptPrefixes` exists so a base-class waiver cannot
silently cover a subclass that uses the property for real.

### Standing rules this audit learned the hard way

- Parse declarations from the **MO2 live tree**, never the repo mirror.
- **For substrate-backed rewards, check the substrate record's VMAD before
  concluding anything is unwired.** A manager property may be a teardown-only
  vestige.
- A property absent across an entire family is that family's shape, not a defect
  in the family.
- Confirm the houseCARL instance *and* profile before any readback that becomes a
  claim -- a wrong-instance read returns a plausible wrong answer, not an error.
