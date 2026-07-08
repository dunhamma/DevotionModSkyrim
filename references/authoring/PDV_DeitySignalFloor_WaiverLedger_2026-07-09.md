# PDV Deity Signal-Floor Waiver Ledger - 2026-07-09

Scope: the 20-positive / 10-negative COMBINED per-deity floor (quest-reaction
matrix + day-to-day likes/dislikes + Part D faucets for Princes) set for the
Tranche10 signal-floor expansion. This ledger is the deity-level waiver record;
it is distinct from the generated per-PATH `PDV_SignalFloorLedger.md` audit.

Locked decisions: thematic-adjacent extrapolation allowed (exact stages only, no
generic membership/progress/radiant rows); Daedric Princes stay quest/faucet-only
in the day-to-day lane; the floor is a target with documented waivers, never a
padding mandate.

Delivered this pass (Tranche10 + LD v15):

- `PDV_QuestReactionMatrix_Tranche10_SignalFloor.csv`: 87 rows (Full.csv 884 -> 971
  cells, 90 -> 122 watched quests, 118 -> 153 quest keys).
- `PDV_DeityLikesDislikes.csv`: 340 -> 363 rows; codegen folded into
  `PDV__ManagerQuest.psc` (`LIKES_DISLIKES_VERSION` 14 -> 15; clear-superset
  extended with event IDs 303, 366); compile 0 errors / 0 warnings.
- Gates: tranche merge PASS, matrix compile --check/--json PASS, adversary check
  PASS (expected thin-Hist warning only), verify 3546 PASS / 0 FAIL / 1
  pre-existing WARN (medallion glyphs), formal-offer PASS, strict
  dislike-consequence audit PASS.
- Proof boundary: authority/readback/static only. NO in-game runtime or manual
  proof yet; see the Tranche10 Codex handoff smoke matrix.

## Final combined tallies

Columns: quest+/quest- | LD+/LD- | faucet+ -> pos/neg (floor 20/10).

At/above floor both sides: Trinimac (20/10), Arkay (20/10), Auri-El (20/12),
Dibella (20/13), Molag Bal (20/14), Leki (20/19), Akatosh (30/10), Stuhn (28/13),
Mehrunes Dagon (30/11), Kyne (35/13), Shor (31/18), Malacath (36/15),
Mara (29/25), Stendarr (31/33), Z'en (19/10, -1 pos tracked).

| Deity | pos | neg | gap+ | gap- | status |
|---|--:|--:|--:|--:|---|
| Namira | 3 | 2 | 17 | 8 | WAIVED (structural) |
| Sanguine | 5 | 0 | 15 | 10 | WAIVED (structural) |
| Peryite | 4 | 4 | 16 | 6 | WAIVED (structural) |
| Sheogorath | 4 | 5 | 16 | 5 | WAIVED (structural) |
| Vaermina | 10 | 1 | 10 | 9 | WAIVED (partial recovery) |
| The Hist | 8 | 5 | 12 | 5 | WAIVED (by-design thin) |
| Clavicus Vile | 15 | 0 | 5 | 10 | WAIVED (lore positive-only) |
| Hermaeus Mora | 23 | 0 | 0 | 10 | WAIVED (lore positive-only) |
| Nocturnal | 23 | 0 | 0 | 10 | WAIVED (readback gap) |
| Hircine | 18 | 1 | 2 | 9 | WAIVED (single dislike axis) |
| Meridia | 15 | 5 | 5 | 5 | WAIVED (domain mined out) |
| Syrabane | 11 | 9 | 9 | 1 | WAIVED (thin domain) |
| Y'ffre | 16 | 7 | 4 | 3 | WAIVED (Green Way pass deferred) |
| Zenithar | 16 | 13 | 4 | 0 | WAIVED (radiant-only remainder) |
| Boethiah | 43 | 3 | 0 | 7 | WAIVED (cowardice-only axis) |
| Mephala | 39 | 3 | 0 | 7 | WAIVED (readback gap) |
| Talos | 39 | 4 | 0 | 6 | WAIVED (cowardice-only axis) |
| Tsun | 34 | 4 | 0 | 6 | WAIVED (cowardice-only axis) |
| HoonDing | 25 | 4 | 0 | 6 | WAIVED (cowardice-only axis) |
| Xarxes | 24 | 6 | 0 | 4 | WAIVED (stages exhausted) |
| Tu'whacca | 19 | 6 | 1 | 4 | WAIVED (no vampirism axis) |
| Julianos | 20 | 7 | 0 | 3 | tracked only |
| Magnus | 20 | 7 | 0 | 3 | tracked only |
| Sithis | 20 | 7 | 0 | 3 | WAIVED partial (readback gap) |
| Azura | 20 | 8 | 0 | 2 | tracked only |
| Kynareth | 21 | 8 | 0 | 2 | tracked only |
| Alkosh | 23 | 8 | 0 | 2 | tracked only |
| Baan Dar | 30 | 8 | 0 | 2 | tracked only |
| Khenarthi | 20 | 9 | 0 | 1 | tracked only |
| Rajhin | 23 | 9 | 0 | 1 | tracked only |
| HoonDing/Tsun/Talos day-to-day | - | - | - | - | negative pressure carried by LD 366 rows |

## Waiver rationales

Each waiver names the surfaces that carry the deity's felt identity instead.

- **Namira (3+/2-)**: Part B profile is cannibalism(C) + desecrate_the_dead(S)
  with no meaningful disapprove axis; vanilla has no second player-cannibalism
  quest. Carried by: DA11 branch triple (feast s100 / spurn s250 / destroy s500
  - the s500 destroy row is new this pass), Ring of Namira faucet, Daedric path
  script. Structural; revisit only if a future pass adds freeform sources.
- **Sanguine (5+/0-)**: Part B gives Sanguine NO disapprove tags ("asceticism -
  rare"); valence must come from Part B, so zero negative rows are authorable.
  New this pass: DA14Start s70 drinking-contest row (borderline; see smoke
  list). Proposed skooma faucet lives in the Codex handoff.
- **Peryite (4+/4-)**: spread_order_pestilence has exactly one vanilla quest
  (DA13, fully covered incl. QE branches); serve_empire_order expansion locked
  to the single representative CW oath stage (review A9). Carried by faucets +
  Daedric path.
- **Sheogorath (4+/5-)**: remaining madness/chaos quests already watched or
  IN_EXCL_AUDIT; DA15WabbajackQST REJECTED (quest_filter `Test\`, likely never
  runs in normal play). Proposed Wabbajack staff-fire faucet in handoff.
- **Vaermina (10+/1-)**: +6 this pass (five Black Book dream-trance echoes +
  MQ04). Only profiled negative is the destroy_reject branch, already authored
  (DA16 s200). No second anti-Vaermina act exists in vanilla.
- **The Hist (8+/5-)**: by-design thin; the adversary check's expected warning
  asserts this. The unwatched candidate pool (Solstheim/Dawnguard) has zero
  Argonian root/sap/memory material. Carried by Argonian P2 substrate + LD lane
  (334 tend-the-hist etc.). Do not force rows.
- **Clavicus Vile (15+/0-)**: Part B: "disapprove: (none meaningful)". Killing
  Barbas with the Rueful Axe is a deal Vile himself offers - cannot be a
  negative. Remaining deceit candidates (MS01/MS02, DBDestroy) absent from
  stage readback.
- **Hermaeus Mora (23+/0-)**: Part B: "(none meaningful - Mora wants knowledge
  by any path)". Positive-only by design; whole Dragonborn arc + 5 Black Books
  added this pass.
- **Nocturnal (23+/0-)**: sole disapprove is expose_betray_secret(m); the only
  player expose-branches (MS02 betrayal, DBDestroy) are absent from stage
  readback. Add on readback refresh (see follow-up 2).
- **Hircine (18+/1-)**: only disapprove is cure_undeath (lycanthropy); C06 s65
  already rowed; "Purity" (Farkas/Vilkas cures) absent from readback - flagged
  for readback extension.
- **Meridia (15+/5-)**: disapprove space (necromancy/desecrate/vampirism) fully
  mined: Soul Cairn arc (VQ04/VQ05 new), VQ03Vampire (new), DA01 s110, DA11
  s100. Remaining undead-slaying content is radiant (DLC1RH*/RV*, excluded) or
  absent from readback (Forbidden Legend, The Wolf Queen Awakened).
- **Syrabane (11+/9-)**: protective-magic domain thin in vanilla; MG arc mined
  by tranche9; +5/+7 added this pass (Skaal/stones/Miraak protection positives;
  Black Book + MQ05 blood-bargain + TTR4a negatives, all framed as reckless
  Daedric/blood exploitation, never dislike-of-study). Remaining headroom is a
  future day-to-day ward-casting lane - Syrabane is NOT an LD actor today and
  would need new-actor wiring (handoff item).
- **Y'ffre (16+/7-)**: +4 this pass (T03 s105 gentle branch, DLC2SV01/SV02
  stone cleansing, DLC1VQ06 Ancestor Glade rite). Further Green Way negatives
  belong to the deferred environmental/behavioral signal pass
  (green-way-signals-deferred).
- **Zenithar (16+/13-)**: +8 this pass (Raven Rock/Thirsk labor lane). Remainder
  of the unwatched trade/labor pool is radiant or unverifiable (RRFavor05
  collectible loop; ElmusBack near-duplicate; RRFavor06/07 semantics unread).
- **Cowardice-only axis (Talos 39/4, Tsun 34/4, HoonDing 25/4, Boethiah 43/3)**:
  sole Part B disapprove is cowardice; no vanilla stage encodes player-chosen
  craven flight (fail stages are giver-deaths/timeouts). Talos additionally:
  Concordat compliance "scores nothing; never a gain" - Imperial branches
  cannot become losses. HoonDing: generic-combat exemption honored (nothing
  re-added). Day-to-day negative pressure added instead (event 366 rows for
  Talos/HoonDing this pass).
- **Mephala (39+/3-) / Sithis (20+/7-)**: strongest negatives (MS02 betrayal,
  DBDestroy) not in stage readback. DB02 s220 (refuse Astrid, kill her) added
  as the verified destroy-DB entry point for Sithis.
- **Xarxes (24+/6-)**: only vanilla desecration stage (DA11 s100) already his;
  DB11 regicide added; nothing further stage-verifiable.
- **Tu'whacca (19+/6-)**: Part B gives him no embrace_vampirism axis (that lane
  is Arkay's); all honor_the_dead stages already rowed; VQ08 slay_undead
  top-up added. One short of pos floor; tracked only.

## 2026-07-09 addendum - cowardice-axis expansion + Boethiah/Mephala Companions review

User-authorized theology change: the cowardice-signal gods (Talos, Tsun,
HoonDing) now also disapprove treachery/assassination. Part B updated and 14
DB-questline dislike rows added (Talos 6, Tsun 4, HoonDing 4). Plus 8 lore-clean
negatives for low deities on existing axes (Arkay/Tu'whacca necromancy via Soul
Cairn VQ04/VQ05; Kynareth necromancy; Magnus reckless_magic DA01; Julianos
sow_chaos DB11 + reckless_magic TTR4a). Full.csv 971 -> 993 cells. New quest
dislike counts: Talos 0->6, Tsun 0->4, HoonDing 0->4, Julianos 3->5, Magnus
3->4, Kynareth 3->4, Arkay 5->7, Tu'whacca 2->4.

**Boethiah & Mephala + Companions: NO clean dislike (investigated, not added).**
Both Princes already APPROVE the entire Dark Brotherhood assassination line (~10
rows each) and their Part B is pro-treachery/assassination/deceit. Boethiah's
only disapprove is `cowardice`(C); Mephala has NO disapprove axis at all
(positive-only by design). The Companions questline (honor, brotherhood, open
combat, curing lycanthropy) contains no player act either Prince scorns - it is
not cowardly, and its hidden Circle-lycanthropy secret is if anything
Mephala-adjacent-positive. Forcing a Companions dislike would contradict their
theology. Per the "not concerned about Princes - they have other signals"
guidance, left as-is; their thin negatives are by design.

## Follow-ups (routed to the Codex handoffs)

1. Part D faucet proposals (Sanguine skooma, Sheogorath Wabbajack staff-fire) -
   need Papyrus hooks before entering the faucet CSV; anti-double-bank caps
   specified in the handoff.
2. **Readback refresh request (highest value)**: add MS01/MS02/DBDestroy/
   C05-Purity ("Purity") to `pdv_extract_quest_stage_readback.mjs` output.
   Unlocks: Mephala +2 neg, Nocturnal +1 neg, Sithis' strongest negative
   (DBDestroy), Hircine +2 neg (Purity cures), Clavicus deceit positives.
3. Borderline rows to prove or drop at smoke: DA14Start s70 (start-handler
   quest), DLC2RRFavor01 s200 (keep-vs-report framing), T03 s105 (absent from
   readback CSV; accepted by compile via the manual FormID path).
4. Syrabane as a future LD actor (new-actor ClearRowsForDeity + version bump).
