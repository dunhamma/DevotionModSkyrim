# 1.0 Untested Backlog (2026-07-16)

**What this is:** the 10 RED criteria from a fresh `pdv_1_0_endstate_gate.mjs --run`
(12 PASS / 1 STALE / 10 RED), organised into the sittings that actually close them.

**What this is NOT:** a scope change. Every criterion below stays `post10: false`.
The 1.0 gate remains RED and keeps meaning what it says. Owner decision
2026-07-16: track the untested work, do **not** waive it -- the content ships in
the 1.0 build, so its proof stays a 1.0 gate. Nothing here is a code defect;
it is all play-time evidence.

**Authority:** `PDV_1_0_EndStateContract.json` + a fresh gate run. This doc is a
work-organisation view of that run, not a competing authority. Re-run the gate
**after** the last recompile -- drift voids machine PASSes
([[felt-family-retrocredit-exhausted]]: specs cannot be retro-credited).

**Operator sheet:** `PDV_1_0_CoTest_Runbook_2026-07-10.md`.

---

## A. Per-race sittings (closes 3 criteria at once)

Each race sitting can close its **pacing sign-off**, its **felt-family** slots,
and its **placement hooks** together. This is the highest-leverage grouping --
the contract explicitly says to fold in-world hook proofs into the matching race
sitting.

| Race | Pacing | Felt-family slots | Placement hooks |
|---|---|---|---|
| Argonian | pending | Hist\|boon, People\|boon, Sithis\|boon, Substrate\|substrate-favor, supportSpells\|boon, Neglect-ArgonianHist | -- |
| Dunmer | pending | Azura\|boon, Boethiah\|boon, Mephala\|boon, Reclamation\|boon, Substrate\|substrate-favor, Neglect-Dunmer | -- |
| Bosmer | pending | BanditRoad\|boon, Exchange\|boon, LivingStory\|boon | living-story-community-nature, exchange-debt-redress |
| Orc | pending | OrcCodeHolds\|boon, Neglect-Orc | -- |
| Breton | pending | -- | tradition-choice-readback, knightly-road-vow, green-way-standing |
| Redguard | pending | -- | ashabah-death-duty, hoonding-make-way-cap |
| Altmer | pending | -- | orthodox-costly-enforcement |
| Khajiit | pending | -- | road-home-circuit |
| Nord | pending | -- | -- |
| Imperial | **signed off 2026-07-11** | -- | focused-patron-civic-favor |

Ledgers: `PDV_PacingSignoffLedger.json` (sign off only after a real sitting, not
a debug-page walk -- records `simLedgerHash`), `PDV_FeltFamilyEvidenceLedger.json`,
`PDV_InWorldHookProofLedger.json` (then re-run `pdv_placement_gate.mjs`).

**Gotchas:**
- Argonian + Dunmer neglect need a **curse ACTIVE** to fire
  ([[neglect-is-four-systems-argonian-dunmer-need-curse]]); prove the Dunmer
  substrate **uncursed first** -- vampirism zeroes it.
- Use direct-seed debug buttons, not organic-mirror ones -- they share the
  daily anti-farm budget and silently no-op same-day
  ([[organic-debug-buttons-share-daily-budget]]).
- Confirm the QR perf-sweep queue is idle first, or stray toasts look like boon
  bugs ([[qr-perf-sweep-queue-contaminates-mcm-sittings]]).

## B. Cross-race felt-family (not race-locked)

Prices: `BaanDar`, `Boethiah`, `Mephala`, `Sithis`, `TheHist`, `Trinimac`, `Zen`.
Disfavor: `Disfavor-VoidSecrets|disfavor-sting`.

Per-deity boons grant only when the deity is the **ACTIVE patron** -- debug needs
piety **and** a patron override ([[patron-family-boon-needs-patron-override]]).

## C. Dedicated sittings

- **C-REQUIEM-TRACKB** -- 4 sweeps (A, B1, B2, C) per
  `PDV_RequiemSmokeTest_Tracker.md` Track B; in-game HP-bar proof.
- **C-DISLIKE-DEBUFF-TUNING** -- 1 slot (`antiStackRequiemFelt`). Confirm the
  32-source disfavor stack stays legible under Requiem alongside neglect and
  prince prices: no over-stack, stings fade, ordinary play unstung.
- **C-MAIN-QUEST-FULL-COVERAGE-RUNTIME** -- 5 probes (mq106 Syrabane, mq206
  mixed-valence, mq101 Sheogorath alias, mq105 paired-equity, Paarthurnax
  expanded forks/latches). Record route + Book of Days + toast + Survey + repeat
  + save/load into `PDV_1_0_ManualSignoffLedger.json`. Pre-T11 Paarthurnax
  waivers do **not** close the expanded-roster slot.

## C2. Design questions for in-game review

Not gate criteria and not release blockers. These are calls the data cannot make
on its own; settle them at the keyboard.

- **Akatosh and dragon-slaying: which way does he fall?** (queued 2026-07-16,
  owner-deferred to in-game review.) `PDV_DeityLikesDislikes.csv` has
  `akatosh | kill-dragon | - | -0.75` -- he is displeased by a slain dragon.
  `docs/player-guides/races/Breton.md:18` tells players the opposite: "Akatosh -
  the Dragon God of time and order; **patron of dragonslayers** and the keeping
  of oaths." Akatosh is reachable for Bretons, so a Breton who reads that line,
  kills a dragon, and watches Akatosh's piety fall has found a shipped
  contradiction.

  Not a typo and not a key-casing bug -- checked: all 13 `akatosh` rows use the
  same lowercase actor key, and `kyne` is lowercase too and dispatches fine. Both
  readings are defensible in lore (dragons are Akatosh's kin; Cyrodiil also
  worships Akatosh Dragonslayer), so this is a design fork, not a defect. The mod
  has to pick one.

  Resolve either way and the loser needs an edit: fix `Breton.md:18`, or flip the
  CSV row positive (which needs a `LIKES_DISLIKES_VERSION` bump plus codegen
  regen, and only proves out on a new save -- see
  [[likes-dislikes-csv-codegen]]). Check how it actually reads in play before
  ruling: how often a Breton meets a dragon, and whether a piety drop there feels
  like theology or like a bug.

  The mod page draft currently uses this contrast as its opening hook (Talos
  `+1.5` against Akatosh `-0.75`). The owner has hand-edited their ship copy, so
  this does **not** block the page.

- **Nine of sixteen Daedric pacts have a Requiem-inert boon or price.** (found
  2026-07-17 while tabling the boon/price data.)
  `PDV_DaedricBoonPriceReviewSheet.csv` gives these effects as **percentage
  regeneration**, which is exactly the effect class Requiem switches off -- the
  mod's own stated reason (`Devotion_Overview.md`) for using flat pools
  everywhere else. So on Pilgrim's Path (authored for Requiem), these silently
  do nothing:
  - **Prices that vanish** (pact becomes cost-free): Azura, Vaermina, Sanguine,
    Clavicus Vile, Hermaeus Mora, Peryite -- all a `Stamina/Magicka regeneration
    -N%` price.
  - **Boons that vanish** (pact gives nothing at that slot): Sheogorath, Namira,
    Hircine.

  This is the same "flat Restore, not rate" pattern already fixed for the race
  rewards ([[requiem-proof-heal-flat-restore-not-rate]]); the Daedric boon/price
  layer was not swept. It intersects the felt-family gate, whose OPEN list
  already carries several Daedric prices. Not a copy bug and not a page blocker
  -- the numbers are correctly tabled from the sheet; the sheet's effect *type*
  is the issue. Convert the regen effects to flat pool changes (or accept them as
  vanilla-only and say so), then re-check under Requiem.

## D. Packaging / external

- **C-COMPAT-BORDELLO** -- 6 sign-off slots (JOJ, TOT, HOH, MOM, DoD, VOV), but
  only **2 real build-targets**: DoD-base and JOJ-base share the
  religion-removal set ([[bordello-compat-two-build-targets]]). ~1 session of
  packaging work, not 6. Confirm the per-list -> base mapping at packaging time;
  the gate still records one sign-off per list so none is silently skipped.
- **C-COMPAT-ARR** -- deliver the ARR/Authoria evidence packet per the
  `pdv-compat-package` workflow; needs **external maintainer acceptance**
  (not closeable solo).

## E. Gate-contract fixes (desk work, no game needed)

Both are the same failure class: **a gate expectation lagging a deliberate
change**. Neither is missing work. Toolchain edits need an explicit ask
(Claude.md rule 5), so both are flagged, not patched.

- **C-EXPMODE-BUILD** -- **stale contract.** The verifier wants
  `PAGE_MODE` / `BuildModePage()` in `PDV_MCM.psc`, but the Experience Mode tab
  was deliberately removed on 2026-07-16 and folded into Settings;
  `ToggleExperienceMode()` and the Path label both PASS. The gate expectation
  needs updating to match the shipped design. See
  [[expmode-gate-contract-stale-vs-shipped]].

- **C-MAIN-QUEST-FULL-COVERAGE** -- **stale contract (new 2026-07-16, 11th RED).**
  `pdv_main_quest_full_coverage_audit.mjs` fails
  `Paarthurnax kill roster: actual=16, expected=17`. Commit `58c5b567`
  (merged `bbe337ab`, `fix/paarthurnax-alkosh-double-fire`) **intentionally**
  removed the Alkosh row from the global `HandlePaarthurnaxKill` roster -- the
  kill path already routes `RouteKhajiitAlkoshChaosAid`, so Khajiit players took
  the hit twice and no other race could reach the row. Alkosh stays on the SPARE
  fork. The fix is correct; the audit's `expected=17` was not updated with it.
  **Owner call needed:** confirm 16 is the intended kill-roster size and update
  the expectation. Until then this reds the rollup for a wrong reason.
  Other 18 checks in that audit pass (1125/1125 cells, 45/45 glyphs).

> **Count note (2026-07-16):** this doc was written against a
> 12 PASS / 1 STALE / 10 RED run. A parallel Codex session landed the Alkosh fix
> mid-session, moving it to **11 PASS / 1 STALE / 11 RED**. The new RED is the
> stale expectation above, not new untested content -- the backlog of *play-time*
> work is unchanged. See [[codex-commit-sweep-reverts-shared-files]] for why
> parallel commits must be checked before blaming a local edit.

## F. Rollup (closes itself)

- **C-AUDIT-BETA-STRICT** -- meta-gate; fails closed while any of the above is
  open. Not separately actionable.

---

## Suggested order

1. **E** (desk fix) -- removes the one RED that reds for a wrong reason.
2. **A** -- 9 race sittings; each closes pacing + felt + placement together.
   Argonian and Dunmer are the heaviest (6 felt slots each).
3. **B** + **C** -- fold the cross-race prices and dedicated sittings in.
4. **D** -- packaging; start the ARR maintainer conversation early, it has an
   external dependency and cannot be closed on your own schedule.
5. Re-run `pdv_1_0_endstate_gate.mjs --run` **last**, after the final recompile.

**Update 2026-07-17:** step 6 (rename and upload) has already happened. The
official distribute file is **`dist/Devotion-1.0.0.zip`** (SHA256 `9140A089...`,
216 entries, verifier PASS), renamed by the owner from the `1.0-rc1` build --
byte-identical, re-verified after the rename.

The owner shipped 1.0 ahead of the gate. **That does not close anything in this
document.** Every criterion above stays `post10: false`, the gate still reads
11 RED, and the in-world proof is still owed -- it is now being burned down
against a public release rather than before one, which raises the cost of a bad
find rather than removing it. Nothing here is retro-credited by the version
number.
