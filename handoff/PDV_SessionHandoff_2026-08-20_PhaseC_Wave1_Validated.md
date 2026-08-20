# Session handoff -- 2026-08-20: Phase C wave 1 validated, dedup half done

Resume pointer for the 2.0 rebuild. All work is committed on **`feature/v3-origin-extraction`**
(nothing pushed). The build in **`Devotion-V3Dev`** is fully deployed and fresh (0 source drift,
116/116 `.pex`, includes wave 1 + the shrine fix).

---

## Where the rebuild stands

| Phase | State |
|---|---|
| A -- debt closeout & truth-up | **done** (A1 manifest, A2 region map, A3 provider seam, A4 parity) |
| B -- QUESTREACTION completion | **done** (whole subsystem moved into its module; B3 metadata trued up) |
| C -- ORIGIN base dedup | **~half done** -- 73 deleted + 142 emptied = **215 of 605** duplicates neutralized; **wave-1 runtime-validated** |
| D -- design gates (PRISMA hook, debug module) | **drafted & merged** (`b492bfa3`), awaiting extraction |
| E -- RECOGNITION + PRISMA extraction | not started (gated behind C finishing) |

Manager is **371 functions** (from 407); "owes a module" **146** (PRISMA 114 + RECOGNITION 31).

## This session's commits (on top of the D-gate merge `b492bfa3`)

- `f1922847` A2 -- region map rebuilt to current reality (1449 fns, 0 missing/dup)
- `944bb025` A1 -- release manifest reconciled to 116 scripts (silent-skip trap closed)
- `0466b71e` A3 -- 3 gain multipliers moved out of the manager (provider seam finished)
- `12061127` B  -- QUESTREACTION: whole subsystem (28 fns + 4 accessors + 28 vars) into its module
- `495b6611` B3 -- region map + contract trued up for the QR move
- `40877ee6` C  -- deleted the 73 provably-dead base duplicates
- `e739f79f` C  -- **cast-safety audit** of the 292 externally-named base duplicates
- `0d80578c` C  -- **emptied 142 A-tier base duplicate bodies** (wave 1, -2249 lines)
- `b01a3c2d`    -- wave-1 runtime runbook
- `639e2959`    -- shrine-prayer journal label fix (see "corrections" below)
- `c6f4a0b7`    -- backlog: MCM Status page redundancy
- `eba4eca9`    -- track the stale manager-QUST property-fill strip as Phase-6 cleanup

Each source change: compile 0/0 (isolated) + static parity (requalify-only, 0 lost). Proof
buckets kept separate throughout.

---

## Phase C -- the real shape (READ THIS before continuing the dedup)

The plan's "delete the 627 duplicate bodies" was an oversimplification. The base is the
**polymorphic dispatch surface** that **473 external `OriginRuntime.<lanefn>` calls** compile
against, so only the provably-dead ones can be deleted outright (73). To neutralise the rest
without touching 473 call sites, the **owner-chosen mechanism is EMPTY-BODY**: replace a safe
duplicate's base BODY with a stub, keep its declaration. For the safe set the base body never
runs (call sites are race-gated), so this removes the dead lines, unlocks the property
consolidation, and defuses the shadowed-var landmine -- with zero call-site churn.

- **Safety map:** `references/authoring/PDV_2_0_ORIGIN_CastSafetyAudit_2026-08-19.md` --
  171 A-tier (strong race gate) + 4 B-tier safe; **116 C-tier need review** (39 read-only,
  77 side-effecting) + 1 multi-race.
- **Wave 1 (done):** the 142 = A-tier INTERSECT the deletable set (not pulled into must-keep by
  a base-internal caller). The other ~28 A-tier stay because a surviving base fn calls them.
- **Deletable ceiling under empty-body:** ~231 more become emptyable once the 116 C-tier are
  cleared; the remaining ~301 are truly load-bearing until a later switchboard/virtual-routing
  pass removes the declarations too (cosmetic, deferred).

## Runtime validation -- wave 1 is BEHAVIOURALLY validated

Owner ran fresh saves on **Nord and Breton** (Devotion Dev profile, Devotion-V3Dev):
- Status page renders each race's content (no blank/None), startup complete.
- Quest reaction (MQ102 s160) and shrine prayer both surfaced to the Book of Days (= backend
  ran -- the BoD is written by the same piety/reaction path).
- **Curse check passed:** became a vampire (`player.addspell 000ED0A8` + `player.addtofaction
  000C4DE0 1`, then **sleep in a bed** -- the refresh fires on `eventbus_sleep`/dawn, NOT on
  `wait`), and the **Status `curse` row flipped to VAMPIRE**. No wrong-race curse text -- the
  emptied `Apply<OtherRace>CurseHandlers` stayed dormant (each race's own handler lives on its
  adapter; the base stub is never hit). Breton has no race-specific vampire toast BY DESIGN
  (`ApplyBretonCurseHandlers` sets state + the Druidic fork, no message) -- the generic curse
  toast is correct.

**Conclusion: the empty-body mechanism is cleared. Resume the dedup waves.**

## Next, in order

1. **Wave 2 -- B-tier (4) then the 116 C-tier review.** For each C-tier: is a non-owning race
   able to reach the call site, and does the base body do non-trivial work for them? 39
   read-only first (lowest risk), then 77 side-effecting. Every one that clears joins the empty
   set; empty in batches, compile 0/0 + parity + a spot runtime.
2. **Deploy + a light runtime re-check** at each batch (build already proven; just confirm no
   new blank/wrong-race).
3. **Then** the switchboard/virtual-routing pass to drop the kept stub *declarations* (cosmetic).
4. **Phase E** (RECOGNITION -> PRISMA, producer-first) once C is done -- PRISMA hook design is
   already drafted (`b492bfa3`).

## Open bugs / debt (tracked, none blocking)

- **Talos renders lowercase in a QUEST-REACTION BoD line** (NOT the shrine prayer -- owner
  corrected). Deep-dived and could NOT reproduce from code: ESP `DeityName = "Talos"`, all three
  reaction surfaces use `GetPublicDeityDisplayName`, nothing writes `DeityName` lowercase. **Need
  the exact BoD line text (or a screenshot)** to find the path. Pre-existing, display-only, not
  from the dedup.
- **Stale manager-QUST property fills** (~34 fills / ~198 "cannot be initialized" warnings --
  deity refs, piety/patron globals). Properties moved to the ledger in earlier phases; ESP still
  fills them on the manager QUST. Tracked as Phase-6 cleanup in
  `references/authoring/PDV_2.0_Branch_Cleanup_and_Decomposition_Plan.md` (Section 6). Harmless,
  blocks the "zero property warnings" acceptance bucket.
- **MCM Status page redundancy** (`summary` = `Patron`+`Standing`; broad-Nine-Divines restated
  4x) -- backlogged to the MCM rebuild in `PDV_WordingRevisionBacklog.md`.
- **`GetQrQueueNeedsBretonRewardSync`** dead getter (no caller) -- for the dead-code sweep.

## Corrections recorded (do not re-derive)

- A3's commit note claimed 3 `pdv_verify` needles needed reconciliation; they did NOT -- Lane A's
  resolver-aware `checkSourceContains` fallback already handles them (proven at A4).
- The shrine-label fix (`639e2959`) is correct but likely addressed the WRONG path -- the earlier
  lowercase was a reaction all along. Harmless (resolves to the same "Talos"); the reaction path
  is the real open bug above.

## Environment / build state

- Branch chain unpushed. `Devotion-V3Dev` = fully deployed current HEAD (verified 0 drift,
  116/116 `.pex` fresh, Talos fix in the manager `.pex`).
- houseCARL instance pointer: **D:/Wabbajack/modlists/Anvil**, profile **Devotion Dev** (was
  already there; not changed this session).
- Debug traces are gated at `GetDebugLevel() >= 2/3`; set FIRST, then trigger, to see piety/curse
  numbers: `set PDV_GLO_DebugLevel to 3` in console (the MCM Debug page was not opening for the
  owner). Papyrus log: `Documents/My Games/Skyrim Special Edition/Logs/Script/Papyrus.0.log`.
- Vampire test forms: `000ED0A8` VampireVampirism spell, `000C4DE0` VampirePCFaction (these are
  what PDV detects -- NOT the Sanguinare Vampiris disease `000B8780`).
