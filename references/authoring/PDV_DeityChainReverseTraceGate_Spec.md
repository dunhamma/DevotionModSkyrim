# PDV Deity-Chain Reverse-Trace Gate -- Spec

**Created:** 2026-06-27. **Status:** BUILT 2026-06-27 -- `tools/pdv_deity_chain_audit.mjs`
(RESOLUTION + REACHABILITY implemented; `--self-test` proves it catches both classes
without false-flagging; integrated into `pdv_integrity_harness.mjs` as a blocking
gate-role check). Future columns below (MGEF-behind-spell, SGE/SEQ, stance, deploy-state,
mirror globals) remain to be added. **Origin:** the Mara / Nord Nine Divines / Orc-Malacath
gaps that 3 audit types + an adversarial pass all missed. See [[deity-chain-audit-2026-06-27]].

## Why this gate exists

Every existing audit is **declaration-driven** -- it verifies what a spec/contract
*lists*, and stays on one side of the Papyrus<->ESP seam. Two failure modes slip
through, both proven this session:

1. **Resolution gap** -- a manager property is declared + referenced in a `Sync*`
   call, but the ESP record it auto-fills from does not exist, so it binds to `None`
   and silently no-ops. *(Nord Nine Divines: 21 reward SPELs; Mara before fix.)*
2. **Reachability gap** -- the records exist and the gate logic is correct, but **no
   organic code path sets the state the gate requires**, so a normal player can never
   reach it. A gate-by-gate audit *passes* while the feature is dead. *(Orc/Malacath:
   `SyncOrcRewards` gate needs `_activeDeity==Malacath`, but `ApplyOrcInitialChoice`
   never set it.)*

You cannot catch either with a checker driven by the same list that has the omission.
This gate is driven by an **independent (race x path x deity) matrix** and asserts every
cell against the **live ESP + live code**.

## The two core assertions (per matrix cell)

- **RESOLUTION:** every reward/neglect/offer/message property the manager *references*
  for this deity resolves to a real, present record in the live `Devotion.esp` (not
  `None`). Walk one level deeper: each reward SPEL's MGEFs exist and have non-zero
  magnitude (the Effects[0] blind-spot lesson -- check every effect index).
- **REACHABILITY:** a normal player can reach the state every reward gate requires.
  For each race, confirm an activation path exists: `ApplyXInitialChoice` sets a patron
  state (broad/active) OR the deity is offer-eligible + has an offer MESG OR a
  path/mode/emphasis state gate the init actually sets.

## Matrix (the audit driver -- NOT the specs)

Source the roster independently (e.g. `PDV_DeityCoverageMatrix.json` + the manager's
offer-eligibility functions), never from `PDV_*RewardRecords.spec.json` (which can omit
a whole lane). Cells:

| Race | Paths/lanes | Focusable deities |
|---|---|---|
| Nord | Old Ways / Nine Divines | Kyne, Shor, Tsun, Stuhn, Mara, Talos / Akatosh, Mara, Arkay, Stendarr, Zenithar, Dibella, Julianos, Kynareth, Talos |
| Imperial | Divines (Concordat-gated Talos) | the 8 Divines + Talos |
| Altmer | offer | Auri-El, Magnus, Xarxes |
| Bosmer | path | Y'ffre, Z'en, Baan Dar |
| Breton | tradition | Stendarr, Julianos, Kynareth |
| Dunmer | Reclamation offer | Azura, Boethiah, Mephala |
| Orc | life-mode (innate Malacath) | Malacath |
| Redguard | sect | Tu'whacca, HoonDing, Leki |
| Khajiit | emphasis (no-offer) | Khenarthi, Azurah, Baan Dar, Rajhin, Alkosh |
| Argonian | substrate (no-offer) | Hist, People, Sithis |
| Daedric | pact (separate gate exists) | 16 Princes |

## Columns to assert (each = a past incident class)

reward SPEL+MGEF present & resolves · offer + accept/refuse MESG present (offer races) ·
deity QUST + SGE flag + SEQ entry · per-(deity x race) stance correct · earn channel
present **and deployed** (live `LoadRowsForDeity` codegen <-> CSV; quest-matrix JSON <->
CSV) · manager VMAD property filled (non-None) · Prisma icon key + Ledger driver +
non-blank Book-of-Days resolver + toast · mirror global (CK condition reads) · FormList
membership + manifest order · neglect SPEL+MGEF · medallion selectable + option-id map.

## Ground-truth method

Live ESP via Mutagen/houseCARL (the same bridge `pdv_verify` / `pdv-phase20-race-author`
use), NOT the repo CSVs -- the deploy-state columns specifically must read the *deployed*
artifacts (`SKSE/Plugins/StorageUtilData/...`, the live `.pex`).

## Integration & acceptance

- Add as a mode/companion to the Integrity Harness so it runs every gate bundle.
- Output: one row per (race x path x deity x column) = PASS / GAP / BY-DESIGN, with the
  6 known by-design suppressions from [[deity-chain-audit-2026-06-27]] explicitly listed
  (don't re-flag them).
- **Self-test:** after this session's fixes (Mara + 7 Nord ND reuse + Orc activation +
  Khajiit icon), a correct gate must report **0 blockers**. Before the fixes it must have
  reported exactly the 9 blockers the workflow found -- use that as the regression fixture.

## Implementation notes

1. Parse the manager for every `Sync*RewardFamily` / `SyncRaceRewardSpell` call ->
   (deity, tier, spell-property) map = the CODE-intended set (this is the axis the
   spec-driven audits lack).
2. Cross-check each property's editorid against the live-ESP record set (resolution).
3. Per race, statically analyze `ApplyXInitialChoice` + the offer-eligibility function +
   the reward gate to confirm reachability (does an organic path set the gate's state?).
4. Reuse the by-design suppression list; fail-closed on anything new.
