# PDV Phase 21 — Authoria/ARR Extension Map

Status: living implementation artifact for the ARR extension + compat-closeout patch
(branch `feature/arr-extension-and-compat-closeout`). Companion to the approved plan and to
`PDV_Phase21_ARR_ConflictDossier.md` (the replacement/compat slice). This file owns the
**extension** angle: lighting up new devotion signals from the list's extra content.

Architecture (locked): **tiered** — vanilla + Creation Club hooks → CORE PDV matrix; third-party
new-land hooks → a separate ARR-scoped matrix JSON loaded by a generic second-channel loader in
`PDV_PlayerEvents.psc`, plus the reserved ESL `PDV_AuthoriaARR_Compatibility.esp` for record-level
adapters. Roster is LOCKED — extension = new SIGNALS to existing deities/Princes, never new gods.

Surfaces: **S1** quest-reaction matrix (FormID|stage, data-only) · **S2** Daedric Prince senders
(vanilla-locked, 16 guards) · **S3** P2 receivers · **S4** location triggers · **S5** shrine
adapters · **S6** faucets.

Cross-plugin safety (verified): runtime resolves `Game.GetFormFromFile(local, plugin)`
(`PDV_PlayerEvents.psc:1190`) and silently no-ops absent plugins (`:752-773`,
`PDV__ManagerQuest.psc:985,995`). This holds at the STAGE level too: a matrix row keyed to a
QE-added stage simply never fires for players lacking that QE mod (the stage never exists).

---

## Wave 0 sourcing dossier (houseCARL vs ARR "PDV Test" profile, 2026-06-15)

Profile state: **PDV Test** active — Archon.esp INACTIVE, Devotion.esp ACTIVE.

### Daedric coverage already owned by S2 senders (DO NOT re-hook in S1 — double-fire)
DA10 House of Horrors `022F08` s200 = Molag Bal · DA13 The Only Cure `08998D` s100 = Peryite ·
DA06 The Cursed Tribe `03B681` s200 = Malacath · DA08 The Whispering Door `04A37B` s60 = Mephala.

### CC questlines (separate FormIDs — clean S1 additions)
| Questline | Deity | Plugin | QUST EditorID | FormID | Terminal stage | Tier note |
|---|---|---|---|---|---|---|
| Gray Cowl of Nocturnal | Nocturnal | ccbgssse020-graycowl.esl | ccBGSSSE020_Quest | `00080F` | 100 | CORE (clean CC) |
| The Cause "Caught in a Web" | Mehrunes Dagon **(VERIFY theme)** | ccbgssse069-contest.esl | ccBGSSSE069_Quest | `000805` | 100 | CORE — confirm Dagon theming before authoring |
| Saints & Seducers (CC base A) | Sheogorath | ccBGSSSE025-AdvDSGS.esm | ccBGSSSE025_QuestA | `000912` | 2000 (900 epilogue) | CORE — Saints path 420/425/430, Seducers path 520/525/530 |
| Saints & Seducers (CC base B) | Sheogorath | ccBGSSSE025-AdvDSGS.esm | ccBGSSSE025_QuestB | `000913` | 200 | CORE |
| S&S — SEC override (ARR-live) | Sheogorath | Skyrim Extended Cut - Saints and Seducers.esp | EC_SS_MQ101 | `099D19` | 52 | LIST-PATCH (SEC clears CC base stages in ARR) |
| S&S — SEC override (ARR-live) | Sheogorath | Skyrim Extended Cut - Saints and Seducers.esp | EC_SS_MQ102 | `09EF5F` | 100 | LIST-PATCH |

NOTE: in ARR the CC-base S&S stages are emptied by SEC, so the CORE CC-base hook will not fire
there — hence the dual-tier S&S coverage (CORE for plain CC, LIST-PATCH for the SEC questline).

### QE mods (override vanilla DA quest FormID; only NEW stages are candidates)
| QE mod | Plugin | Vanilla quest | Candidate added stage(s) | Outcome (needs stage-text confirm) |
|---|---|---|---|---|
| House of Horrors QE | HouseOfHorrorsQuestExpansion.esp | DA10 `022F08` | **210** | post-s200 Molag Bal aftermath epilogue |
| The Only Cure QE | TheOnlyCureQuestExpansion.esp | DA13 `08998D` | **101, 102** | 101 acceptance variant / 102 refusal-or-alternate |
| The Cursed Tribe QE | The Cursed Tribe - Quest Expansion.esp | DA06 `03B681` | **210, 220, 230** | extended Malacath aftermath chain (s200 stays S2-owned) |
| The Whispering Door QE | The Whispering Door - Quest Expansion.esp | DA08 `04A37B` | 41–45 (pre-s60 branch) | mid-quest decision cluster; no post-terminal stage → low value, likely skip |

---

## Open Wave-1 inputs (before authoring theology cells)
1. **Stage-meaning sourcing**: pull the journal/log text for each candidate stage (HoH 210; Only
   Cure 101/102; Cursed Tribe 210/220/230; CC terminals; SEC 52/100) so deity/valence/intensity/
   magnitude/act-tags are authored from the real outcome, not a guess. houseCARL `read_record` on
   each QUST's stage log entries (ARR profile), or vanilla-quest-stage-readback for the DA bases.
2. **Verify "The Cause" theme** (`ccbgssse069-contest.esl` ccBGSSSE069_Quest) is Mehrunes Dagon.
3. **FormID registration**: CC/SEC FormIDs are not in `vanilla-quest-stage-readback.csv` → add to
   `MANUAL_QUEST_FORMIDS` (`tools/pdv_quest_matrix_compile.mjs:114`) or extend the readback CSV,
   else the compiler throws (`compile.mjs:161`). QE-added stages ride the vanilla DA FormIDs
   (already resolvable) but DA10/13/06 must be in the S1 matrix watch list for the new stage to route.

## Wave-1 authoring targets (CORE unless noted)
- QE: (022F08,210)→Molag Bal · (08998D,101/102)→Peryite · (03B681,210/220/230)→Malacath. Whispering
  Door QE deferred (no terminal-side stage).
- CC: (00080F:ccbgssse020-graycowl.esl,100)→Nocturnal · (000805:ccbgssse069-contest.esl,100)→
  Mehrunes Dagon (post-verify) · (000912:ccBGSSSE025-AdvDSGS.esm,2000)+(000913,200)→Sheogorath.
- LIST-PATCH (ARR JSON): (099D19:SEC,52)+(09EF5F:SEC,100)→Sheogorath.

---

## Sourcing corrections (2026-06-15, deep pass)

CHANNEL INFRA BUILT + COMPILING: `pdv_quest_matrix_compile.mjs` now takes `--matrix <csv>` +
honors an inline `formid` column; `PDV_PlayerEvents.psc`/`PDV__ManagerQuest.psc` carry a generic
second-channel loader (core always; `PDV_QuestReactionMatrix_ARR` when present). Both .psc compile
0/0; core `--check` still PASS. No-ops with no ARR JSON, so base PDV is unchanged.

**DROP — "The Cause" / Mehrunes Dagon CC:** `ccbgssse069-contest.esl` ("Caught in a Web") is a
spider-dungeon quest, 0% Mehrunes Dagon. The real CC The Cause = `ccBGSSSE059-BattleofFortSungard.esl`,
**NOT in ARR**. No Mehrunes Dagon CC hook. (Mehrunes Dagon still reachable via vanilla DA07 S2 sender.)

**TOOLCHAIN LIMIT — externalized strings:** Vigilant.esm / Glenmoril.esm / Unslaad.esm store quest
journal text in external `.strings`; houseCARL/Mutagen returns `(absent)` for every stage log entry.
Structural data (quest names, EditorIDs, FormIDs, stage indices) IS readable; only prose is not.
=> author marquee cells from quest-name/EditorID + established lore, confirm terminal stage NUMBERS
via a houseCARL structural read, cite EditorID+stage (journal-prose citation unavailable by design).

**Verified Wave-1 CORE set (text-confirmed where embedded):**
- Gray Cowl of Nocturnal `00080F:ccbgssse020-graycowl.esl` s100 → **+Nocturnal** (receive the Cowl). CORE.
- House of Horrors QE `022F08:Skyrim.esm` s210 → **+Stendarr, −Molag Bal** ("helped Tyranus destroy
  the altar"). NOTE: the QE winner removes vanilla s100, so in ARR the quest is anti-Daedric. CORE
  (vanilla-FormID-keyed; no-ops without the QE).
- The Only Cure `08998D:Skyrim.esm` s101 → **−Peryite** (refuse); s102 → **−Peryite, +Stendarr**
  (kill Orchendor + destroy altar). s100 (+Peryite) stays owned by the S2 sender — do NOT re-add. CORE.
- The Cursed Tribe `03B681:Skyrim.esm` s210 → **+Malacath (indirect)** (ghost-variant). s200 (+Malacath
  Champion) stays S2-owned; s220/230 text absent → skip. CORE (low signal — optional).
- Whispering Door QE: dropped (no terminal-side stage).

**ARR JSON (LIST-PATCH) confirmed:**
- Saints & Seducers SEC override `09EF5F:Skyrim Extended Cut - Saints and Seducers.esp` s100 →
  **+Sheogorath** (defeat Thoron, serve Staada/Dylora). Saints vs Seducers branches are NOT
  theologically distinct (both serve Sheogorath). CC base ESM text is externalized + SEC overrides it
  in ARR → the SEC hook is the live one; the CC-base CORE hook is optional/unverifiable.
- Vigilant/Glenmoril/Unslaad/Olenveld → ARR JSON, authored from structure+lore. Olenveld has embedded
  text: `OlenveldBOTE 50FC4D:Olenveld.esp` s80 → **+Arkay** (cleanse the Ideal Masters' undeath).
  Wyrmstooth = low signal (mercenary dragon-hunt, no divine-service framing) → defer.

**Top marquee targets (Vigilant, lore-clear; stage numbers pending structural read):**
Stendarr+ : zzzAoMMq00 "Vigilant of Stendarr" 005CE2; zzzAoMMq08 "No Mercy" 00EA8A; zzzAoMMqGoodEnd
"Art of Mercy" 4D0376. Molag Bal− : zzzBMMq03 "The Blood Matron" 038526; zzzCHMQ00 "Coldharbour"
12F24E. Akatosh+ : zzzCHMQ01 "Aetherius" 1363DB. Knight sub-quests (Coldharbour) → +Arkay/Kyne/
Julianos/Kynareth/Zenithar (zzzCHSubQuest07/08/10/12, Archer of Kyne 1279A1). Child of Oblivion
065932 → −(Daedric pact).

---

## AUTHORED (2026-06-15) — ARR channel, machine-validated

`references/authoring/PDV_QuestReactionMatrix_ARR.csv` → compiles via
`pdv_quest_matrix_compile.mjs --matrix <csv> --output <ARR.json> --check` = **PASS (23 cells / 19
keys / 18 quests)**. All target deities confirmed as established matrix deities (no silent-drop).
Tool gotcha fixed: inline `formid` column uses **PLUGIN:HEX** order (not houseCARL's HEX:Plugin).

Authored cells (all in the ARR channel for a self-contained patch; core matrix left FROZEN):
- Vigilant: No Mercy→+Stendarr, Art of Mercy→+Stendarr, Coldharbour→−Molag Bal, Aetherius→+Akatosh,
  Knight of Arkay/Kynareth/Julianos/Zenithar→+that Divine, Archer of Kyne→+Kyne.
- Glenmoril: Rite of Cannibalism→+Namira/−Arkay, Azura→+Azura.
- Unslaad: Loveletter→+Akatosh, Trial of the Gods→+Tsun/+Stuhn.
- Olenveld→+Arkay; SEC S&S→+Sheogorath.
- QE (vanilla FormIDs): HoH s210→−Molag Bal/+Stendarr; Only Cure s101→−Peryite, s102→−Peryite/+Stendarr.
- CC: Gray Cowl s100→+Nocturnal.

RUNTIME-VERIFY (no ShutDownStage flag — stage may not fire as authored; confirm at smoke, adjust CSV
if needed): Vigilant Aetherius/Archer of Kyne (s255), Knight of Julianos/Zenithar (s999), Glenmoril
Azura (s10).

DEFERRED (flagless 9999 dev-ceiling / ambiguous valence / curse-layer): Vigilant zzzAoMMq00 (join),
Blood Matron, Child of Oblivion; Unslaad Long Winter; Glenmoril Or-the-Gospel / Mark-of-the-Hunter
(Hircine = curse-layer, route via curse system not S1); Cursed Tribe QE s210 (low signal); Wyrmstooth
(no divine-service framing).

PROMOTE-TO-CORE candidates (deferred to a reviewed step, gated on the paired-equity audit, per the
tiered decision): Gray Cowl (CC) and the QE vanilla-FormID hooks — currently ARR-channel-only.

NEXT: deploy ARR.json into the ARR test mod + runtime-smoke the firing (Wave 2); then promote
CC/QE to core after equity check.

### Addendum (2026-06-15, offsite data-only pass)
- ForgottenCity AUTHORED (embedded text, high confidence): FC Quest02 s1500 refuse-to-murder→+Stendarr;
  FC Quest01 s4000 persuade-Arbiter→+Julianos; FC Quest01 s4050 reunion→+Mara. ARR channel; --check
  PASS at **26 cells / 22 keys / 20 quests**.
- "The Cause" / Mehrunes Dagon: CONFIRMED ABSENT (ccBGSSSE059 master not loaded; only an inert
  orphan LOTD stub patch). Permanently dropped — Mehrunes Dagon stays covered by vanilla DA07.
- DAc0da: RESOLVED via web research (Vicn's Numidium prequel). AUTHORED 2 HIGH-confidence cells to the
  ARR channel: Worm Cult zDcdSqWorm `0052C2` s9999 → +Arkay (defeat Mannimarco; no join path); main arc
  zDcdMq05 `00CA1E` s999 → +Akatosh (expel the Numidium; no enable path; RUNTIME-VERIFY the stage fires
  on success, not the Mantella bad-ending). DEFERRED: Pan-Argonia zDcdMqArgoEnd `00CA5B` s30 — a
  bad-ending trap (Hist overruns Nirn via Numidium activation); valence ambiguous + quest-ID→scene
  mapping unconfirmed.

CHANNEL COUNTS (current): ARR channel = 22 cells / 20 keys / 19 quests (the original 26 less the 6
promoted to the core matrix via Tranche6, plus 2 DAc0da). Core matrix = 383 cells (+6). Supersedes the
"26 cells" figures elsewhere in this doc.

## Wave 6 (man_DaedricShrines shrine adapters) — INVESTIGATED, NOT VIABLE as a clean override
Definitive ACTI scan (2026-06-15): the man_DaedricShrines family is STAT-based (mesh/statue replacers),
NOT ACTI. Zero of the 16 Princes expose a clean route anchor; the only ACTIs are Nocturnal x2, both
carrying TempleBlessingScript (PDV must not replace global activator scripts). Jyggalag/Sithis/Kynareth/
Mara = STAT only; Mehrunes Dagon = worldspace placement only. Vanilla shrine ACTIs (Azura/Mara/Kynareth/
Divines) carry TempleBlessingScript and are won by skymojibase.esl, not man_. => A shrine-prayer adapter
would need EITHER (a) PDV-placed invisible marker ACTIs / trigger volumes at the shrine cell positions
(new ESP + placement + runtime), OR (b) a location-trigger hook (new PDV_FLST_HolySites + manager
handler; note coc skips location triggers). Both are ESP/runtime + design decisions — HELD for review.
No clean data-only adapter exists. Wave 6 data-only investigation = DONE.

CONFIRMED by a placed-reference trace (2026-06-15, not just base records): only the two Nocturnal
activators are clickable — man_ShrineOfNocturnal (00090F:man_DaedricShrines.esp) + the TG09 vanilla
override (10E8B0:Skyrim.esm), BOTH TempleBlessingScript->AltarNocturnalSpell (10E8AE), which is ALREADY
in PDV's shrine-blessing manifest (so the man_ Nocturnal shrines are already covered). The other 15
Princes (Mehrunes Dagon/Jyggalag/Sithis/Azura/Namira/Mephala/Sanguine/Herma-Mora/Sheogorath/Vaermina/
Molag Bal + Kynareth/Mara statues) place only STAT/decor — no ACTI, no script, no blessing spell, no
clickable. PDV-placed markers or a location-trigger hook remain the only path for those 15 (ESP/runtime/
design decision).

