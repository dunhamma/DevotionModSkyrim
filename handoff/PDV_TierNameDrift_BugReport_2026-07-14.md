# PDV Bug Report - Player-Facing Tier-Name Drift (Blessing Records)

**Date:** 2026-07-14
**Scope:** `Devotion.esp` SPEL/MGEF Name (FULL) fields; per-race reward spec JSONs; live Papyrus tier-label helpers
**Status:** Source (specs) FIXED. ESP write QUEUED, BLOCKED on ESP lock. Two decisions open.
**Evidence basis:** direct `housecarl_*` reads of the live `Devotion.esp` (Anvil instance) + live-source `.psc` grep. No runtime/in-game proof claimed.

---

## 0. TL;DR for the reviewer

The originating ticket described this as "8 blessing spells still carry retired design-sheet tier names (Observant/Faithful); rename them to the shipped Seeker/Devoted/Champion."

**That premise is false and acting on it would have shipped a regression.**

PDV runs **two parallel player-facing tier ladders**. `Faithful` is not retired vocabulary - it is the live, shipped name of the **broad-worship lane's** top rung. The genuine bug is smaller, different, and sits almost entirely in the **T1** row.

| Ticket claimed | Actually true |
|---|---|
| 8 drifted records | **12** drifted records |
| `Imperial_Civic_T1` already fixed in ESP ("- Seeker") | ESP says **"- Observant"** - not fixed |
| Specs carry the retired names; ESP is ahead | **Specs are mostly RIGHT; the ESP drifted.** Every spec already encodes T1=Seeker / T2=Faithful |
| Rename all `- Faithful` -> `- Devoted` | Would **mislabel** a maxed broad worshipper as mid-ladder |

---

## 1. Root cause: there are TWO ladders, not one

### Patron lane (a focused active patron)
`None -> Seeker (25) -> Devoted (50) -> Champion (85)`
Source: shipped UI `native/DevotionPrismaBridge/mod/PrismaUI/views/Devotion/app.js`, `thresholds` array.

### Broad-worship lane (`PATRON_STATE_BROAD`, no focused patron)
`Seeker (25) -> Faithful (50)` - and it **stops at Faithful. It never reaches a T3/Champion.**

```papyrus
; PDV__ManagerQuest.psc:627-628
Float Property BROAD_PANTHEON_SEEKER_THRESHOLD   = 25.0 AutoReadOnly
Float Property BROAD_PANTHEON_FAITHFUL_THRESHOLD = 50.0 AutoReadOnly
```

Five independent shipped surfaces agree the broad 50-gate is called **Faithful**:

1. `app.js:1280` - the broad gauge is literally `[{ label: "Seeker", value: 25 }, { label: "Faithful", value: 50 }]`
2. `PDV__ManagerQuest.psc:14115-14119` - the grant sites pass the display names `"The Divines' Regard - Faithful"`, `"Old Ways - Faithful"`, `"Faith of the Holds - Faithful"`
3. `PDV_DiegeticDirector.psc:360` - `"You reached Faithful. The pantheon turns to look."`
4. The manager's own gate variables are named `imperialFaithful` / `oldWaysFaithful` / `nineFaithful`
5. `PDV_RedguardRewardRecords.spec.json` states the intent outright:
   > `"threshold": "broad-worship state, capped at Faithful (broad lane stops here; never reaches T3)"`

**Consequence of the ticket's proposed fix:** broad standing caps at 50. `Devoted` is the *middle* rung of the patron ladder (cap 85). Renaming the broad T2 rewards to `- Devoted` would tell a player who has **maxed** the broad lane that they are mid-ladder, implying a Champion rung they can never reach on that lane - while the gauge rendering beside it still reads "Faithful". This is the regression the fix would have introduced.

**Why the trap is easy to fall into:** both ladders share the same T1 word (`Seeker`) *and* the same 50-point gate value. A single-ladder mental model looks correct right up until it silently relabels the broad lane.

---

## 2. The actual bug: the T1 row

Five T1 spells contradict **their own magic effects**. The player sees the SPEL name in the magic menu and the MGEF name in Active Effects - so a single reward currently presents under two different tier words.

| # | FormID | EditorID | SPEL Name (live) | its own MGEF says | Correct |
|---|---|---|---|---|---|
| 1 | `071071` | `PDV_Bless_Imperial_Civic_T1` | `The Divines' Regard - Observant` | `- Seeker` (0710B8, 071568) | `- Seeker` |
| 2 | `071073` | `PDV_Bless_Nord_OldWays_T1` | `Old Ways - Observant` | `- Seeker` (0711B3) | `- Seeker` |
| 3 | `0716C4` | `PDV_Bless_Nord_NineDivines_T1` | `Faith of the Holds - Observant` | (untiered) | `- Seeker` |
| 4 | `07106F` | `PDV_Bless_Dunmer_Reclamation_T1` | `Reclamation Communion - Faithful` | `- Faithful` (071156) | `- Seeker` |
| 5 | `071069` | `PDV_Bless_Argonian_Hist_T1` | `Hist Communion - Faithful` | (untiered) | `- Seeker` |

Rows 4-5 are the nastiest: a **Seeker-tier (25 piety) blessing tells the player they are "Faithful"** - wrong on *either* ladder.

Corroboration that `Seeker` is right for broad T1: the threshold constant is named `SEEKER`; the grant sites pass `"The Divines' Regard - Seeker"` / `"Old Ways - Seeker"` (`PDV__ManagerQuest.psc:14114-14118`); the T1 MGEFs already say `- Seeker`; and every spec already says `- Seeker`.

### Records CORRECTLY named - do not touch
All broad-lane T2 records reading `- Faithful` are **correct as shipped**: `0710BB` Imperial_Civic_T2, `0711B6` Nord_OldWays_T2, `0716C5` Nord_NineDivines_T2, `0711E7` Bosmer_Yffre_T2, `07112D` Orc_Malacath_T2, `071196` Redguard_AncestorSpine_T2, `071211` Breton_Tradition_T2, plus their 12 matching MGEFs.

Also **not** a bug: MGEF *Descriptions* using "the faithful" as ordinary prose ("The Code-Keeper steadies the faithful", "A faithful citizen of the Empire"). That is flavor, not a tier claim. Same for the MESG "outcast-faithful" (`07137D`, Namira). Leave all of it.

---

## 3. Dead copy (retired records)

Hard-wired `False` in the manager - never granted, so no player ever reads these names. Included in the queued write for re-author safety only; **zero gameplay effect**.

| FormID | EditorID | Retired at | Name now | Queued |
|---|---|---|---|---|
| `071069` | `PDV_Bless_Argonian_Hist_T1` | `ManagerQuest:15383` | `Hist Communion - Faithful` | `- Seeker` |
| `071114` | `PDV_Bless_Argonian_Hist_T2` | `ManagerQuest:15384` | `Hist Communion - Devoted` | `- Faithful` |
| `071113` | `PDV_MGEF_Argonian_Hist_T2_ResistDisease` | (same family) | `Hist Communion - Devoted` | `- Faithful` |
| `071211` | `PDV_Bless_Breton_Tradition_T2` | `ManagerQuest:14301` | `Tradition's Footing - Faithful` | (already correct) |

Note the Argonian spec was *internally contradictory*: `"tierCap": "Faithful"` alongside `"displayName": "... - Devoted"`. The queued change resolves it in the direction its own `tierCap` states.

---

## 4. Work completed this session

### 4a. Specs reconciled (DONE, committed to worktree)

The specs were the *reliable* side - only 5 fields were wrong. JSON re-validated, ASCII-clean. Zero `Observant` now remains in any spec.

```
references/authoring/PDV_ArgonianRewardRecords.spec.json | 4 ++--
references/authoring/PDV_DunmerRewardRecords.spec.json   | 2 +-
references/authoring/PDV_RedguardRewardRecords.spec.json | 4 ++--
```

| File | Before | After | Why |
|---|---|---|---|
| Dunmer:137 | `Reclamation Communion - Faithful` | `Reclamation Communion - Seeker` | T1 entry carried a T2 word |
| Argonian:171 | `Retired Argonian Relation - Faithful` | `Hist Communion - Seeker` | wrong tier word **and** base name diverged from ESP |
| Argonian:190 | `Retired Argonian Relation - Devoted` | `Hist Communion - Faithful` | resolves the `tierCap` contradiction; aligns base name |
| Redguard:158 | `Ancestor Spine - Seeker` | `Ancestors' Regard - Seeker` | **base-name drift**: a re-author would have RENAMED the shipped spell |
| Redguard:174 | `Ancestor Spine - Faithful` | `Ancestors' Regard - Faithful` | same |

The Redguard rows are worth calling out separately: the tier word was fine, but the *base* name in the spec (`Ancestor Spine`) never matched the shipped ESP (`Ancestors' Regard`). A re-author would have silently renamed a live, player-visible spell. That is a latent bug the ticket did not know about.

### 4b. ESP write - QUEUED, NOT APPLIED

**Blocked: Skyrim is running.** Identified precisely via the Windows Restart Manager rather than guessed:

```
PID 26356 : SkyrimSE  ->  D:\Wabbajack\modlists\Anvil\Stock Game\SkyrimSE.exe
StartTime : 2026-07-14 10:44 PM  (up 29 min at time of check)
```

houseCARL refused cleanly: `IOException: The process cannot access the file ... the existing file is untouched`. **Nothing was written to the plugin.** The game was not killed (owner presumed mid-smoke-test).

- Backup taken: `D:\Wabbajack\modlists\Anvil\mods\Devotion\Devotion.esp.bak-tiernames-2026-07-14` (637,461 bytes, byte-identical)
- Queued: one `housecarl_bulk_apply`, `target=Devotion.esp`, `in_place=true`, **8 operations, `Name` field only** - no effects, no magnitudes, no FormIDs, no conditions.
- Verification plan: direct `housecarl_read_record` readback of all 8 Names. That readback IS the proof (per `AGENTS.md` houseCARL rule). No bridge/adapter/proof-ledger.

**Queued operations:**

| FormID | Type | Name -> |
|---|---|---|
| `071071` | SPEL | `The Divines' Regard - Seeker` |
| `071073` | SPEL | `Old Ways - Seeker` |
| `0716C4` | SPEL | `Faith of the Holds - Seeker` |
| `07106F` | SPEL | `Reclamation Communion - Seeker` |
| `071069` | SPEL | `Hist Communion - Seeker` |
| `071156` | MGEF | `Reclamation Communion - Seeker` |
| `071114` | SPEL | `Hist Communion - Faithful` |
| `071113` | MGEF | `Hist Communion - Faithful` |

**To resume:** close Skyrim, then re-run the single `bulk_apply` + readback. No other prerequisite. Records are Name-only, so no recompile and no new save is required for these 8.

---

## 5. OPEN DECISION 1 - Dunmer `Reclamation_T2` (`071159`)

A **live** broad-lane reward named `- Devoted` while its six sibling broad-T2s all say `- Faithful`.

- Grant site `PDV__ManagerQuest.psc:14831` - `broadReclamationFaithful = isDunmer && GetPatronState() == PATRON_STATE_BROAD && ReclamationFocusCount >= 6`. That is unambiguously the broad lane, `Faithful` gate.
- But `PDV_DunmerRewardRecords.spec.json:151` **deliberately** declares `"tierCap": "Devoted"` and `:154` `"displayName": "Reclamation Communion - Devoted"`. Spec and ESP are *self-consistent*.

So this is either **(a)** an intentional Dunmer exception to the broad-lane cap, or **(b)** the last piece of this bug. I did **not** touch it - changing a live player-facing name against an explicit spec declaration is not a call to make silently.

Affected if changed: SPEL `071159`, MGEF `071157`, MGEF `071158` (all read `Reclamation Communion - Devoted`), plus spec `:151` `tierCap` and `:154` `displayName`.

**Recommendation:** align to `- Faithful`. The broad lane demonstrably caps at 50 for Dunmer exactly as for the other six races, and a lone "Devoted" on a lane with no Champion rung is the same player-facing lie the T1 bug tells.

## 6. OPEN DECISION 2 - three conflicting tier vocabularies in the live scripts

The Papyrus tier-label helpers do not agree with each other or with `app.js`:

| Location | tier 1 -> | tier 2 -> |
|---|---|---|
| `app.js` (shipped UI) | `Seeker` | `Devoted` / broad `Faithful` |
| `PDV_DiegeticDirector.psc:497, 510` | **`Faithful`** | `Devoted` |
| `PDV__ManagerQuest.psc:15716-15718` (`GetBroadLaneStandingLabel`) | **`Observant`** | `Faithful` |
| `PDV__ManagerQuest.psc:15736-15745` (`GetBroadLaneNextThresholdText`) | **`Observant`** at 3 acts / 25 pts | `Faithful` |
| `PDV__ManagerQuest.psc:14114-14118` (grant-site labels) | `Seeker` | `Faithful` |

`PDV_DiegeticDirector.psc:497` mapping tier 1 to `"Faithful"` is the sharpest contradiction: `app.js` maps tier 1 to `"Seeker"`.

Under the two-ladder model the broad helpers should return `Seeker` / `Faithful`, and `Observant` should disappear entirely from player-facing strings. (`GreenPactCompliance` at `ManagerQuest:23373` also returns `"Observant"`, but that is a **different axis** - the Green Pact band Apostate/Lapsed/Observant/Strict - and is **not** in scope. Do not sweep it.)

**Deliberately deferred, not forgotten.** This means editing `PDV__ManagerQuest.psc`, which is (a) flagged as the file parallel Codex `commit -a` sweeps silently revert, and (b) requires a recompile the owner cannot run mid-smoke-test. It wants its own scoped pass with a fresh-save proof, not a bundle into a Name-only ESP fix.

---

## 7. Proof boundary

- **Proven by direct houseCARL read of the live ESP:** every Name value quoted in sections 1-3.
- **Proven by live-source grep:** every `.psc` line/gate cited.
- **Applied and verified:** the 5 spec `displayName` edits (JSON parse + ASCII check).
- **NOT proven:** nothing in this report has in-game runtime proof. The 8 queued ESP edits are **not yet written**. No claim is made that any of this is player-verified.
- **Verification owed on resume:** `housecarl_read_record` readback of the 8 changed Names; optionally one in-game glance at a broad-lane T1 blessing in Active Effects to confirm the SPEL and MGEF finally agree.

## 8. Suggested triage labels

`bug` / `player-facing-copy` / `blocked-on-owner` / `needs-decision`
