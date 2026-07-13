# PDV 1.0 Test Packet -- gate-driven close-out (rewritten 2026-07-07)

Status: orchestrator only; regenerate the live gate before every sitting. A
2026-07-10 read-mode run was RED because source/deployed drift voided older
machine evidence. Supersedes the 2026-07-02 A-F mega-packet structure (Sections
A quest-expansion, B closed races, C1 Prisma, E1 day-to-day all PASSED in
Sitting 1 -- kept only as regression recipes at the bottom).

**What this is.** The single packet that walks the remaining in-game and external
proof needed to close 1.0. It is an ORCHESTRATOR: it owns the order, the save
plan, and the evidence-sink map. The source of truth is the contract +
generated burndown, and on any conflict the burndown wins:

- Gate authority: `references/authoring/PDV_1_0_EndStateContract.json`
- Live status: `node .\tools\pdv_1_0_endstate_gate.mjs` ->
  `references/authoring/PDV_1_0_EndStateBurndown.md`
- Co-testing operator sheet:
  `references/authoring/PDV_1_0_CoTest_Runbook_2026-07-10.md`

**How proof is recorded.** Each proof writes to a structured ledger (the
evidence-sink map, Section 6). Statuses are `pending` / `evidence-recorded` /
`retro-credited` / `not-applicable` -- never `pass`/`done`. Record a result by
reporting it to Claude (who writes the ledger slot with provenance and
regenerates the burndown) or by editing the named ledger directly. The gate
derives PASS; you never hand-write a verdict.

---

## 1. Current gate state (regenerate before every sitting)

The generated burndown wins over this prose. Historical re-green shape after the
2026-07-09 `--run` was 10/18 machine or evidence gates closed, with 8 play or
external RED criteria below. A 2026-07-10 read-mode run reported **1 PASS / 1
STALE / 16 RED** because source/deployed drift voided older machine evidence.
Recertify with `node .\tools\pdv_1_0_endstate_gate.mjs --run` before treating
new in-game observations as 1.0 evidence.

The expected post-recertification open surface remains the play/external gates:

| Criterion | What closes it | Evidence sink |
|---|---|---|
| C-FELT-FAMILY | one in-game felt proof per lane x class family (105 pending) | `PDV_FeltFamilyEvidenceLedger.json` |
| C-DISLIKE-DEBUFF-TUNING | one anti-stack / Requiem-felt sitting | `PDV_1_0_ManualSignoffLedger.json` (dislikeStackTuning) |
| C-PACING-SIGNOFF | 10 dated per-race pacing sign-offs | `PDV_PacingSignoffLedger.json` |
| C-PLACEMENT-FINAL | 10 pending in-world hook proofs | `PDV_InWorldHookProofLedger.json` |
| C-REQUIEM-TRACKB | Requiem felt sweeps A / B1 / B2 | `PDV_1_0_ManualSignoffLedger.json` (requiemTrackB) |
| C-EXPMODE-SMOKE | two-mode runtime smoke | `PDV_1_0_ManualSignoffLedger.json` (experienceModeSmoke) |
| C-COMPAT-ARR | ARR package accepted | `PDV_1_0_ManualSignoffLedger.json` (compatARR) |
| C-COMPAT-BORDELLO | 6 lists patch-packaged | `PDV_1_0_ManualSignoffLedger.json` (compatBordello) |

The race sittings (Section 4) close the first four in a single per-race pass.
Sections 5 close the cross-cutting gates. C-1-0 (the ship gate) flips green when
all eight do.

---

## 2. Preflight (rerun if any code/plugin/reward/Prisma/Daedric file changed)

```powershell
git status --short
node .\tools\pdv_1_0_endstate_gate.mjs            # regenerate the burndown
node .\tools\pdv_verify.mjs --json                # FAIL=0
node .\tools\pdv_dislike_consequence_audit.mjs --strict-dislike-consequence
```

Drift guard: the gate flags `live-vs-deployed-drift` if the git live-source
manager and the MO2 deployed copy differ (e.g. a parallel Codex build mid-flight).
If it fires, sync live-source -> MO2 (or wait for the build to deploy) before
trusting any source-read audit. The debug-MCM dislike/disfavor buttons are BUILT
and deployed (2026-07-07): Developer Options carries a "Dislikes & disfavor"
section -- Dislike event ID slider + **Fire dislike vs selected deity**, domain
cycle + band toggle + **Apply domain sting**, **Anti-stack burst (4 domains)**,
and **Show / Clear active disfavor**. These are how you fire dislikes and stings
from the menu (no in-world transgressions needed).

2026-07-09 deity signal remap addendum: if testing the remap tranche, run
`references/authoring/PDV_DeitySignalRemap_InGameSmoke_Runbook.md` after this
machine preflight. The remap's compile/readback gates make it smoke-ready only;
they do not close runtime-route proof, manual visual proof, or player-guide
claims.

2026-07-10 co-test addendum: for live tester/Codex sessions, start from
`references/authoring/PDV_1_0_CoTest_Runbook_2026-07-10.md`. It consolidates
the signal-floor smoke cards, exact evidence capture template, stop conditions,
and the 1.0 evidence-sink map without replacing this packet or the generated
burndown.

Shared per-sitting setup (unchanged from the proven flow):
- Disposable **new save** (or main-menu `coc qasmoke`); MO2 Anvil: disable
  `Devotion - Living Deities Test` (not present on Authoria).
- Console `set PDV_GLO_OriginRace to <n>` + `set PDV_GLO_DebugLevel to 2`;
  all seeding via **MCM -> Devotion -> Developer Options** (never `cqf`).
- Origin indices: 0 Nord, 1 Imperial, 2 Breton, 3 Altmer, 4 Bosmer, 5 Dunmer,
  6 Khajiit, 7 Argonian, 8 Orc, 9 Redguard.
- Papyrus log: `...\My Games\Skyrim Special Edition\Logs\Script\Papyrus.0.log`.
- Walk location-anchored hooks in via load door / fast-travel (`coc` skips Story
  location-change triggers). Hard-save at the clean start so origin flips reload.

---

## 3. Proof bars (what "felt" means per class -- agreed 2026-07-07)

- **Debug-primed proof is accepted.** Prime patron/piety/pact/curse state via the
  Developer Options page, then observe the real effect. Organic routes are
  already machine-proven by the trace and e2e gates.
- **Boons / substrate / favor:** debug-prime the deity to a tier, confirm the
  spell in Active Effects at the right magnitude. (Daedric: Force Seeker/Devoted/
  Champion.)
- **Neglect / curse / disfavor sting:** felt-mechanic -- the debuff is visible in
  Active Effects (flat, Requiem-felt), plus a one-line feel note.
- **Prices / dislikes (deity):** loss-surfacing -- one displeasing act, then a
  visible toast, Book of Days beat, or panel Ledger row. No felt debuff exists
  for the piety-loss dislikes themselves; the felt layer is the domain sting.
- **In-world hooks:** the hook fires from its REAL context during play (quest
  stage, book, road/tomb/forge), not the QASmoke debug sender.
- **Pacing:** magnitudes/pacing felt right in a real sitting on that race.

---

## 4. Race sittings -- the spine (closes C-FELT-FAMILY, C-PACING-SIGNOFF, C-PLACEMENT-FINAL, and the disfavor felt families)

Print the live checklist for each race:

```powershell
node .\tools\pdv_felt_registry_gen.mjs --sitting <Race>
```

The sheet lists that race's pending boon / substrate / neglect / curse families,
its roster-deity dislikes, AND the disfavor domain stings its transgressions
trigger, plus the pacing sign-off reminder. One pass per race, four moves:

1. **Boons.** For each boon family: Developer Options -> select deity ->
   Target piety 85 -> Apply -> confirm the boon in Active Effects.
2. **Neglect / substrate / curse** (where the race has them): Prime neglect
   eligible -> Run neglect pass -> confirm the debuff; set focus/substrate/curse
   via the dedicated setters and confirm.
3. **Dislikes + disfavor stings.** Set standing (Target piety 25), then
   **Fire dislike vs selected deity** for each roster deity's transgression:
   confirm the loss surface (toast / BoD / Ledger) AND the domain sting in Active
   Effects. Shared domains prove once across all sittings.
4. **In-world hook proof** (only the races with pending hooks -- Altmer, Khajiit,
   Redguard, Bosmer, Breton, Imperial; see the hook ledger): reach the one pending
   hook from its real context and confirm the route.
5. **Close:** record the race's pacing sign-off.

Report results to Claude (or edit the ledgers): felt families ->
`PDV_FeltFamilyEvidenceLedger.json`; pacing -> `PDV_PacingSignoffLedger.json`;
hook proofs -> `PDV_InWorldHookProofLedger.json`.

**Recommended order (light -> heavy):** Bosmer (6) -> Dunmer (8) -> Argonian (8)
-> Redguard (8) -> Orc (10) -> Altmer (11) -> Breton (11) -> Khajiit (12) ->
Nord (24 with all disfavor domains) -> Imperial (heaviest boon set). Start with
Nord if you want to shake out the debug-prime workflow on the most-documented
race first; either way the 7 shared disfavor domains finish early and drop off
later sheets.

**Pending in-world hooks (10, fold into the owning race sitting):** Altmer
orthodox-cost; Khajiit road-home; Redguard Ash'abah death-duty + HoonDing
make-way (make-way overlaps Requiem Sweep B2 -- one act, two gates); Bosmer
Living Story + Exchange; Breton tradition readback + Knight's Road vow + Green
Way standing; Imperial focused-patron civic favor.

---

## 5. Cross-cutting gates

### 5a. Disfavor anti-stack tuning (Anvil) -- closes C-DISLIKE-DEBUFF-TUNING
One dedicated sitting after the disfavor stings are felt individually. Use the
debug buttons: **Anti-stack burst (4 domains)** -> confirm the 3-domain cap holds
and the 4th is suppressed; confirm stings are felt on the HP/stat bar under
Requiem, fade on schedule, and that sub-band acts / no-standing characters stay
unstung. Sink: `PDV_1_0_ManualSignoffLedger.json` (dislikeStackTuning).

### 5b. Requiem felt sweep (Authoria) -- closes C-REQUIEM-TRACKB
Run `PDV_RequiemSmokeTest_Tracker.md` Track B; feel is only provable on Authoria.
Magnitudes PROVISIONAL -- record tuned values as notes, do NOT re-run
cumulative-rebalance tools (not idempotent).
- **Sweep A:** each converted Fortify-Health reward felt (`player.getav Health`
  before/after + HP bar); A7 Mara sleep-mercy, A8 Dunmer home-prayer ancestor
  watch (once/day near-death restore, no instant heal), A9 Orc Code Holds.
- **Sweep C (2026-07-13):** each converted Fortify-Magicka/Stamina reward felt as a
  POOL MAX rise (`player.getav Magicka/Stamina` returns current -- read the bar MAX
  / Active-Effects "Fortify Magicka/Stamina" entry). Race boons +15/+25/+40; Daedric
  Sheogorath Magicka / Hircine Stamina +25/+40/+50; Argonian Sithis near-death is
  now a scripted flat `RestoreActorValue("Stamina",100)` (instant restore, not a
  regen bar). Any race already M/S-felt-proven is INVALIDATED, re-prove here.
- **Sweep B1:** Redguard Tu'whacca event-heal, Namira heal-on-feed (tier-scaled,
  caps), Ash'abah stigma (Survey label, no piety drop), Breton Vigilant nod.
- **Sweep B2:** HoonDing dragon make-way once/day (+ decay on repeat, generic
  bandit silent, named boss dedups), Champion cheat-death save. (Make-way also
  closes the Redguard HoonDing in-world hook.)
- **Penalty feltness:** Argonian Hist Distant -10 max Health, Breton Tradition
  Distant -10 / Excommunication -15 (Active Effects Maximum Health label, bar
  ceiling drops), Imperial civic lapse stays ResistDisease -5 with no Health
  effect; Nord Orkey's Neglect = Magic Resist -5%, Dibella's = Restoration -5.
  **(2026-07-13) M/S neglect/creed-loss penalties now felt too:** Altmer/Dunmer
  neglect -10 Maximum Magicka, Bosmer/Khajiit neglect -10 Maximum Stamina, Breton
  `DruidicForkBetrayal` -15 Maximum Stamina (bar ceiling drops in Active Effects).
Sinks: `PDV_1_0_ManualSignoffLedger.json` (requiemTrackB) + the Redguard/Daedric
blocks of `PDV_Phase20_ManualEvidenceLedger.json`.

### 5c. Experience Mode two-mode smoke (Anvil) -- closes C-EXPMODE-SMOKE
Now unblocked (build gate closed). Fresh save Pilgrim's Path: mode readback
correct, economy at authored rates, MCM shows the mode. Toggle Wayfarer's Path:
manager scalars apply, cheap-repeatable handling relaxes, save/load keeps the
mode. Sink: `PDV_1_0_ManualSignoffLedger.json` (experienceModeSmoke).

### 5d. Compatibility (repo + external) -- closes C-COMPAT-ARR, C-COMPAT-BORDELLO
Codex/repo work, not a play sitting. ARR/Authoria integration package delivered
and accepted by the maintainer (start early -- acceptance has external latency);
the other six Bordello lists (JOJ, TOT, HOH, MOM, DoD, VOV) reach patch-packaged.
Sinks: `PDV_1_0_ManualSignoffLedger.json` (compatARR, compatBordello).

---

## 6. Evidence-sink map

| Proof | Ledger | Gate |
|---|---|---|
| Boon / substrate / neglect / curse / disfavor / dislike felt | `PDV_FeltFamilyEvidenceLedger.json` | C-FELT-FAMILY |
| Per-race pacing sign-off | `PDV_PacingSignoffLedger.json` | C-PACING-SIGNOFF |
| In-world hook fired from real context | `PDV_InWorldHookProofLedger.json` | C-PLACEMENT-FINAL |
| Disfavor anti-stack / Requiem tuning | `PDV_1_0_ManualSignoffLedger.json` (dislikeStackTuning) | C-DISLIKE-DEBUFF-TUNING |
| Requiem Track B sweeps | `PDV_1_0_ManualSignoffLedger.json` (requiemTrackB) | C-REQUIEM-TRACKB |
| Experience Mode smoke | `PDV_1_0_ManualSignoffLedger.json` (experienceModeSmoke) | C-EXPMODE-SMOKE |
| ARR + Bordello | `PDV_1_0_ManualSignoffLedger.json` (compatARR / compatBordello) | C-COMPAT-* |
| Disfavor per-race raw run notes | `PDV_DislikeConsequence_TestLedger.json` | (feeds felt families) |

---

## 7. Stop conditions (abort, bring back notes)

- an accepted source fires for the wrong race, or generic gameplay becomes a
  scoring faucet
- a generic act scores a non-native god (race-gate leak)
- **a disfavor sting bites ordinary play** (a sub-0.5 act, or a character with no
  standing with the offended deity)
- **disfavor stings over-stack past 3 domains, do not fade, or read as a
  regen-rate change under Requiem instead of a flat penalty**
- an uncommitted transgressive Prince path deepens from an ambient act
- Survey/status shows route IDs / raw counters instead of player wording
- a reward, price, or sting stacks invisibly or cannot be explained from the UI
- Prisma opens as a BLOCKING panel where only a toast/notification is expected
- save/load changes visible state unexpectedly
- any Book of Days line renders BLANK

---

## 8. After the run

1. Record results into the named ledgers (Section 6) -- report to Claude or edit
   the slots; never write `pass`/`done`.
2. Regenerate: `node .\tools\pdv_1_0_endstate_gate.mjs` and read the burndown.
3. Fold any defect into its tracker; magnitude/anti-stack notes feed the tuning
   pass. Re-run the affected machine gate if source changed.
4. **Exit criterion:** C-1-0 flips green when all eight play/external criteria
   are recorded. That -- not any prose here -- is 1.0 test-complete.

---

## Explicitly post-1.0 (do not test for 1.0)

WS-3 branding, FP-049 journal, the residual C2 Prisma cosmetic beats (Altmer
band, Khajiit Champion pin, Redguard sect toast -- fold in opportunistically
during those race sittings if convenient, but they do not gate), Mega Sitting F
Prince V2 path-deepening (Prince price felt families already credited), voiced
dialogue / recognition V2, Bosmer Green Pact per-item tags, Jyggalag. See
`post10Exclusions` in the contract.

---

## Appendix: regression recipes (already PASSED in Sitting 1 -- rerun only on regression)

These closed on 2026-07-05/06 and are NOT part of the 1.0 remaining queue. Rerun
only if the named source changes.

- **A. Quest Expansion smoke** (832 cells / 118 keys / 90 quests; meta-faucets;
  reachability gate; A10 aggregated toast+BoD). Source:
  `PDV_SessionHandoff_2026-07-05_QuestExpansion.md`. Regroup by origin; fire cells
  with `setstage <editorID> <stage>`.
- **B. Closed race strict-gate packets** (Imperial 2026-07-04, Dunmer 2026-07-05).
  Do not retest without a route/surfacing/reward change.
- **C1. Universal Prisma U1-U9** (panel/Book close, tier gauge, favor/dawn digest,
  neglect lapse/recovery, offer accept/refuse copy). Source:
  `PDV_RunSheet_Universal_Prisma_V1.md`. Blank Book of Days line = FAIL.
- **E1. Day-to-day signal sweep** (likes/dislikes deltas CSV-exact, race-gate,
  anti-farm, dawn bank). Source: `PDV_InGameTestingNeeded_Runbook.md` section 5.
  Note: the dislike side of this now ALSO fires the disfavor stings (Section 4).
- **C3. Cold-view focus-trap** re-confirm after any Prisma DLL rebuild.
