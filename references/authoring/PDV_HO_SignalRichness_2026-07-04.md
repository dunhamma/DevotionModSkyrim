# PDV Handoff -- Signal Richness: Azura Gap Fixes + Cross-Race Audit (2026-07-04)

Owner-approved 2026-07-04 from the Dunmer/Argonian/Bosmer lane comparison. Two workstreams:
(A) the three Dunmer/Azura fixes, (B) a cross-race signal-richness audit -- the axis the
overstack/variety audit never measured (it scored REWARD stacking; this scores ORGANIC FEEDING:
what vanilla play actually triggers per lane).

Doctrine: gate-first, registry-driven, generated-ledger-as-truth; deterministic -> script,
judgment -> agent. Signals are NOT rewards: adding rows/cells does not touch the overstack
ruling that excluded Breton/Dunmer/Nord/Imperial from variety tranches.

---

## A1. Azura T5 aspect-parity echo pass  [S -- main session, no subagents]

~6-10 new Tranche-5 cells for Azura (domains: souls, twilight/fate, mercy to the cursed and
outcast). Candidate cells to ratify (verify exact quest/stage semantics against
`vanilla-quest-stage-readback.csv` before authoring -- scan-only rows never promote unreviewed):

| Candidate | Direction | Rationale |
|---|---|---|
| Soul Cairn arc (DLC1 VQ hooks: entering bargains vs freeing souls; Arvak returned) | + (free/mercy), - (soul bargains) | souls in bondage are her direct offense |
| DA09 Meridia (The Break of Dawn, complete) | + small echo (one step down) | anti-undeath kinship; dawn imagery |
| Serana cure (VQ epilogue stage if readback-clean) | + medium | mercy to the cursed made whole |
| DG vampire-side soul feeding beats | - | the inverse lane |
| Azura's own DA01 branches | already present (2 cells) | keep; Black Star deviation shipped 2026-07-04 |

Workflow: edit `PDV_QuestReactionMatrix_Tranche5_AspectParity.csv` -> `pdv_quest_tranche_merge`
-> `pdv_paired_equity_audit` (waivers as needed) -> `pdv_quest_matrix_compile --check` -> compile
-> new-save smoke ("0 quest entries" = key-drift tell). Remember `ApplyDeityReaction` name
matching: the deity token must match the live name exactly (azura face resolves via the shared
PDV_Deity_Azura; use the same deity-name token T5 already uses for Azura cells).

**Model: main loop (Fable 5), no fan-out.** Judgment-dense, data-light (grep-scoped readback
rows); a subagent would re-read context for no gain. Owner ratifies the cell table before merge.

## A2. Soul-trap router event + pantheon reaction table  [M -- Codex handoff, manager lane]

New day-to-day event family (vocabulary style: combat-by-victim 300s):
- `369 soul-trap-creature` (white souls)
- `370 soul-trap-black` (humanoid / black soul)

Detection: PO3 Papyrus Extender soul-trap event (verify exact registration + payload via
`pdv_papyrus_lookup` / the housecarl papyrus-reference bundle BEFORE coding; do not guess the
signature). Route `PDV_PlayerEvents`/alias -> `PDV_ActionRouter` -> `PDV_EventBus` like the
existing 36x transgressions. Anti-farm: standard daily cap + 0.7^n decay; black-soul large-tier
cooldown mirrors `365 raise-undead`.

Draft pantheon reactions (owner ratifies values; every affected god gets the CLEAR dislike the
owner asked for -- black-soul trapping is the pantheon-wide bright line):

| Deity | 369 creature | 370 black | Note |
|---|---|---|---|
| Azura (azurah) | + small (soul-work is her craft) | - large | mirrors 365 necromancy severity |
| Arkay | - small (souls belong to the cycle) | - large | strongest claim; death-cycle desecration |
| Meridia | 0 | - medium | fuel of undeath |
| Mara / Stendarr | 0 | - medium / - small | mercy/protection breach |
| Xarxes | 0 | - small | the record defiled |
| Molag Bal / Vaermina (Prince V2 lanes) | 0 | + deepen (path-open only) | deepen-not-initiate holds |

Regen chain is MANDATORY: CSV edit alone is inert -- `pdv_likesdislikes_gen` regen +
`ClearRowsForDeity` superset + `LIKES_DISLIKES_VERSION` bump + new-save proof. Rerun
`pdv_specced_minus_audit` after the sweep (re-instatement regression class).

**Model: handoff authored by main loop; code by Codex** (its own lane/billing). Serialize behind
any open manager work -- this touches ActionRouter/EventBus/ManagerQuest. If Codex is busy, main
loop can build it directly; do NOT fan out subagents for it (single-file-family coherence).

## A3. Twilight-window legibility  [XS -- main session copy pass]

The dawn/dusk prayer bonus (`TryAwardDunmerTwilightWindowSignal`) exists and is invisible to
players. Surfaces to touch (pdv-player-copy rules; Survey stays compact per the 2026-07-04
Survey-compacting ruling -- do NOT re-bloat it):
- Ledger driver row label reads as twilight-marked (verify the reason token renders legibly).
- Dunmer run-sheet 4a note + player-guide Dunmer section: "prayers at dawn or dusk carry further."
- Optional one-line Chronicle flavor on first twilight-window hit (reuse existing surface).

**Model: main loop, trivial token cost.**

---

## B. Cross-race signal-richness audit (the missed axis)

### B1. Deterministic gate (DONE 2026-07-04 -- extraction below; promote to tool)

Extraction over `PDV_SignalFloorLedger.md` (35 race-paths), thinnest first by LD*2+QR:

| Path | LD rows | QR cells | renew | env | flag |
|---|---|---|---|---|---|
| khajiit_khenarthi | 8 | 2 | 2/2 | 2 | THIN-BOTH |
| argonian_hist / people | 11 | 0 | 3/2 | 2 | QR=0: ADJUDICATED by design (harvest/ritual race; PDV_ArgonianHistQuestReaction_Decision_2026-06-25) |
| altmer_magnus | 7 | 8 | 2/2 | 0 | THIN-BOTH + env 0 |
| breton_hidden_art | 0 | 23 | 2/2 | 0 | **LD=0: quest-only lane; a non-quester never feeds it** |
| khajiit_baandar | 9 | 5 | 2/2 | 2 | THIN-QR |
| khajiit_azurah | 11 | 2 | 2/2 | 2 | THIN-QR (shares A1/A2 fixes via shared deity) |
| dunmer_azura | 11 | 2 | 2/2 | 2 | THIN-QR -> fixed by A1/A2 |
| khajiit_alkosh | 10 | 6 | 2/2 | 0 | THIN-QR + env 0 |
| altmer_auriel | 10 | 7 | 3/2 | 1 | borderline |
| argonian_void | 10 | 10 | 2/2 | 0 | borderline; near-death burst carries it |
| (all others) | 10-101 | 11-133 | -- | -- | healthy; Bosmer/Nord/Imperial/Breton-KR/civic are the rich pole |

Khajiit note: the lunar substrate lattice (khajiit_lunar 46/25) carries ambient identity for the
whole race, so per-deity THIN-QR is partially by design -- the judgment pass must score "does the
race feel fed", not just the lane number. Same for Argonian (harvest/ritual).

Promote: `tools/pdv_signal_richness_audit.mjs` -- parse the generated floor ledger, emit this
table + FLAG column with thresholds (LD < 8 = THIN-LD; QR < 8 = THIN-QR; env = 0 = NO-ENV;
LD = 0 or QR = 0 = HARD flag unless waived), plus a waivers CSV for adjudicated-by-design rows
(argonian_hist/people QR, dunmer_deviation LD, breton_hidden_art IF the owner waives instead of
fixing). Wire into `pdv_integrity_harness` as non-blocking INFO first; owner decides if it gates.

**Model: script = free; authoring the script = main loop (mechanical, small).**

### B2. Judgment pass (per-race verdicts)

For each flagged lane: "what does a NON-ritualizing player of the natural playstyle actually
trigger in 10 hours of normal play?" -> verdict fed / thin / thin-by-design + a fix-shape
(T5 echo cells / new LD rows / new event family / waiver). Registry = the B1 table. Evidence =
the lane's actual LD rows + QR cells + faucets (grep-scoped pulls, not whole-CSV reads).

**Model: fan out ONE subagent per flagged race (6-7 agents) on SONNET** -- scoped prompts with
the lane's rows pasted in, so each agent runs a few thousand tokens. Haiku is too weak for
theology-fit judgment; Fable/Opus per-race is wasted spend. Synthesis + owner ruling prep on the
MAIN loop (Fable). Estimated total: well under one race sheet's worth of tokens.

Priority order for fixes coming out of B2 (pre-seeded): breton_hidden_art LD rows (0 is a hole,
not a flavor), altmer_magnus rows + env hook, khajiit per-deity QR echoes (one small T5 pass can
feed BaanDar/Azurah/Alkosh together), khenarthi QR echoes (Kyne-adjacent weather/travel stages).

### Sequencing

1. A1 (this session or next; owner ratifies cells) -> merge/compile/equity gates.
2. B1 tool promotion (same session as A1; mechanical).
3. B2 fan-out (Sonnet agents) -> owner ratifies verdicts -> fixes fold into A1-style passes.
4. A2 Codex handoff (manager lane; after any open manager work lands).
5. A3 rides any copy pass.
All of it stays OFF the strict beta gate -- Dunmer manual evidence remains the only 1.0 blocker;
this is content-depth work that can land during/after beta without touching gate proofs.

## C. Quest-meta-faucets for thin/ceiling deities (proposed 2026-07-05, owner review pending)

Owner insight: quests are FINITE and one-shot, so generic matching rules that would be
farm-bait as day-to-day faucets are safe when keyed to QUEST FULFILLMENT. Mechanism: a single
`EvaluateQuestMetaFaucets(sourceQuest, stage)` pass inside `ApplyQuestReaction` (the one site
every watched quest-stage fire funnels through), with a per-quest once-guard in StorageUtil
(finite by construction: 88 watched quests today, growing with the pool) and per-faucet value
knobs `value.meta.<id>` in the compiled JSON (same zero-Papyrus tuning as the echo tier).
"Completion" = first watched-stage fire of that quest (per-quest guard absorbs multi-stage
quests). Stance gates apply as usual, so foreign faces feel these at 0.4x.

### Recommended (honest theology + trivial detection)

| id | Deity | Trigger at watched-quest fulfillment | Value | Est/playthrough (~60 completions) |
|---|---|---|---|---|
| meta.zen | Z'en (15) | fulfillment of a GOLD-REWARDED quest -- the contract discharged, the wage taken (owner refinement 2026-07-05). Detection is compile-time, not runtime: a curated per-quest goldReward flag (UESP reward data, one-shot tagging of the watched pool) emitted into the matrix JSON as quest.<key>.goldReward; no gold-delta sniffing. Unpaid favors correctly leave Z'en unmoved -- the negative space IS the theology | 0.5 | ~18 (about 60% of the pool pays gold) |
| meta.nocturnal | Nocturnal (20) | TIERED (owner refinements 2026-07-05): fulfillment where a theft-family act (360/361/362) occurred SINCE THE PREVIOUS watched fulfillment -- no same-day requirement (owner: multi-day jobs count); implemented as two stamps, PDV.Meta.LastTheftTime vs PDV.Meta.LastQuestFulfillTime -- fires at 1.5 ("the job done her way"); else fulfillment between 20:00-06:00 ("done in her dark") at 1.0. One fire per quest, whichever lands first. True used-theft-to-complete causation is NOT engine-detectable; theft-between-fulfillments is the honest proxy | 1.5 / 1.0 | ~20-25 |
| meta.azura | Azura (13+6) | fulfillment of a MAGE-AID flagged quest (owner refinement 2026-07-05: College of Winterhold line, Falion, court wizards, mage questgivers -- lore anchor: the Shrine of Azura was built by Winterhold mages) OR fulfillment in the twilight windows (05-07 / 17-19, "sealed at the threshold"). One fire per quest | 1.0 | ~20 |
| meta.akatosh | Akatosh (18) | every 10th fulfillment (lifetime counter) -- "the wheel turns"; endurance through time | 2.0 | ~12 |
| meta.xarxes | Xarxes (16) | same 10th-fulfillment counter -- "the record kept"; the scribe notes the deeds (Altmer face of the same wheel; stance gates keep one player from feeling both) | 2.0 | ~12 |
| meta.khenarthi | Khenarthi (13) | fulfillment while OUTDOORS under the sky -- "the road honored" (alt: fulfillment in a different hold than the last one -- "the road between"; hold-walk detection is fiddlier, offered as V2) | 1.0 | ~20 |
| meta.julianos | Julianos (15) | fulfillment of a MAGE-AID flagged quest (owner ruling 2026-07-05) -- same PDV_QuestClassFlags class as Azura, "wisdom served". His existing College cells make the yield rule below load-bearing for him | 1.0 | ~8 (mage-aid quests where he holds no cell) |

**Yield rule (2026-07-05, applies to ALL meta-faucets):** if the deity already earned a matrix
CELL award on this quest, the meta pass skips that deity for that quest -- meta-faucets are
gap-fillers on top of the matrix, never double-credit. (One StorageUtil check per deity at the
meta pass; the per-quest once-guard already exists.)

Pacing: all six sit at/under the echo-tier envelope (max 30 vs the 34 threshold); each has its
own knob. Ledger acceptance: each fires AwardPiety with a reason token so it lands as a Ledger
driver row (owner rule: every data point in the Ledger).

### Considered and NOT recommended

- **Meridia daylight completions:** symmetric to Nocturnal but a third time-window faucet reads
  as a gimmick pattern; her slay-undead cells + DA09 carry her identity.
- **Rajhin "clean job" (no bounty since quest start):** needs quest-start state tracking we do
  not have; his TG coverage (17) is on-theology already.
- **HoonDing / Hircine:** their event lanes (make-way kills, breakthrough bosses, the hunt) are
  already the right home; quest meta-faucets would double-route the same fantasy.
- **Arkay / Tu'whacca:** rite-shaped domains; temple favor + day-to-day burial rows carry them.
- **Julianos / Trinimac / Sheogorath / Alkosh / Auri-El:** no honest generic exists; ceilings
  stand (Alkosh/Auri-El are near-25 anyway).
- **Thin princes (Namira/Sanguine/Vaermina/Peryite/Clavicus/Mora) + Sithis:** deliberately
  Part-D-faucet / DB-scoped; quest meta-faucets would blur the deviation/price design.
- **Dibella:** one NORMAL matrix milestone instead -- a Bards College full-arc completion cell
  (aesthetic_devotion milestone) if the owner wants her above 14; no meta-faucet.

### Build shape (Codex manager lane, S-M)

Generalized mechanism (2026-07-05): ONE curated class-flag CSV
(`PDV_QuestClassFlags.csv`: editor_id, classes e.g. "gold|mageAid") consumed by
`pdv_quest_matrix_compile` and emitted as `quest.<key>.classes` -- Z'en gold and Azura mage-aid
both read it; future quest classes are a CSV row, not code. `ApplyQuestReaction` gains the meta
pass (per-quest once-guard + class/time/counter checks + reason tokens); the EventBus theft
routes gain the `PDV.Meta.LastTheftDay` stamp; VALUE_TABLE gains the `value.meta.*` knobs
(nocturnal gets theft/night tiers). Curation pass: tag gold + mageAid over the 88 watched quests
(one short Sonnet pass against UESP reward/questgiver data, main-loop spot-check).
Smoke rows: one theft-day fire, one night fire, one mage-aid fire, one twilight fire, the
10th-quest counter; `pdv_ledger_coverage_audit` picks up the new reason tokens automatically
(verify UNTRACKED stays 0).

## C-STATUS: BUILT + ADVERSARIALLY VERIFIED (2026-07-05)

Matrix (832 cells / 90 watched quests) live in the core JSON; all 7 meta lanes implemented per
`PDV_QuestExpansion_Architecture.md` (zero new scripts/records/registrations). Three refuter
agents + main-loop closure:
- Lane liveness: 7/7 LIVE. Every JSON key byte-exact emit-vs-read (incl. metaSkip.Z'en
  apostrophe); values resolve through the float map; deity names all covered by the canonical
  repair EXCEPT Nocturnal (Daedric path, CK-baked) -- closed via houseCARL readback:
  PDV_DaedricPath_Nocturnal DeityName == "Nocturnal" exactly.
- Deployment parity: 832/832 cells round-trip Full.csv <-> live JSON (both representations the
  engine reads); class flags 15/15 rows emitted with zero silent no-ops; metaSkip recomputed
  independently over the full 826-combination cross product, 0 violations; ARR channel zero
  key overlap + core-first lookup order confirmed.
- Unwired-declaration hunt: all new emit/read/storage-key/reason-token pairs CONFIRMED WIRED;
  meta reasons reach the Ledger unfiltered.

FOLLOW-UPS surfaced by verification (fold into the next passes, none block the build):
1. **DEFECT (pre-existing): `EVT_STEAL_ITEM` (362) is declared but never dispatched** -- steal
   acts have never fired the day-to-day steal likes (Mephala/Boethiah/Rajhin) and cannot stamp
   the Nocturnal theft tier. Interim truth: the theft tier fires on lockpick (360) / trespass
   (361), which are already "her way". Owner options for the fix: (a) SM Crime Gold receiver
   (event-driven, thin-glue PDV pattern, but WITNESSED thefts only -- ironic for Nocturnal);
   (b) player-alias OnItemAdded ownership check (catches unseen theft, adds a small hot-path
   handler with early-outs -- the one deliberate exception to script-neutrality if chosen).
2. Meta reason tokens render the generic fallback phrase in the Ledger (HumanizeDriverReason
   has no meta_* arms) -- cosmetic copy pass: add the seven phrases ("the wage taken", "done
   her way", ...).
3. Hardening: Daedric-path DeityNames have no runtime repair net (unlike the 30 deities) --
   consider extending EnsureCanonicalDeityDisplayNames to FLST_DaedricPaths_All.
4. Tester note: stance multipliers apply to meta lanes (foreign faces feel 0.4x) -- do not
   false-FAIL manual smoke on a non-native character.
5. Design note (intended, documented): meta evaluates on the FIRST cell-bearing stage fire per
   quest; class flags emit on all stages by construction so lanes cannot starve each other.

## Model summary (token efficiency)

| Item | Executor | Why |
|---|---|---|
| A1 Azura echoes | Main loop (Fable 5) | judgment-dense, data-light; no fan-out overhead |
| A2 soul-trap event | Codex (handoff by main) | manager-lane code; single-agent coherence |
| A3 twilight copy | Main loop | trivial |
| B1 audit tool | Main loop / script | deterministic; script does the work |
| B2 race verdicts | 6-7 Sonnet subagents, Fable synthesis | parallel small judgments; theology needs mid-tier+, not frontier-per-race |
