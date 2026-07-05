# PDV Session Handoff -- 2026-07-05 Quest-Reaction Notice Surfacing (GAP)

## TL;DR

During Mega Packet Sitting 1 (Block 1 Imperial, on the deployed reachability-gate build),
quest-reaction and meta-faucet piety awards fire correctly but surface **nothing to the player**:
no top-left toast, no Book of Days entry. Confirmed in code -- the quest-reaction path awards
piety silently and never calls any surfacing function. This is a separate work item to be picked
up in its own session; it does NOT block the rest of the smoke run (the route/piety proof still
passes, only the player-facing surface is missing).

## Evidence

**In-game (owner):** ran Block 1 Imperial quest rows; piety visibly accrued but no toast appeared
top-left and no new Book of Days line was written.

**Papyrus log (`Papyrus.0.log`, 2026-07-05 ~14:25-14:28):** every quest fire logs
`AwardPiety` + `QuestReaction piety: <deity> ...`, e.g.:
- `AwardPiety: Julianos raw 6.0 ... (Julianos.disciplined_study)`
- `AwardPiety: Julianos ... (Julianos.meta_julianos_wisdom)`  (meta lane fired)
- `AwardPiety: Dibella raw 6.0 ... (Dibella.aesthetic_devotion)`
- `AwardPiety: Meridia raw 0.8 applied 0.4 stance 1 ...`  (path face at 0.4x)

Zero `AppendBookOfDaysEntry` / `Dispatch` / toast / chronicle emit lines anywhere in the
quest-reaction window. (The reachability gate itself works: many
`QuestReaction skipped unreachable foreign deity: <deity>` traces, TABOO Azura flips negative,
Molag Bal curse-routes -- all correct.)

**Code (`live-source/Scripts/Source/PDV__ManagerQuest.psc`):** the quest-reaction path makes no
surfacing calls.
- `ApplyQuestReaction` (1358), `EvaluateQuestMetaFaucets` (1400), `ApplyQuestReactionFaucet`
  (1475), `ApplyDeityReaction` (1536), `ApplyQuestReactionPiety` (1890), `ApplyQuestReactionStigma`
  (1905) -- none call `AppendBookOfDaysEntry`, `PDV_DiegeticDirectorService.Dispatch`, or any
  toast/notification.
- Contrast -- these paths DO surface: shrine prayer (`AppendBookOfDaysEntry` @3162 +
  `Dispatch("prayer",...)` @3164), substrate acts (Malacath 3921 / Tu'whacca 4071 / Auri-El 4180),
  transitions (`DispatchTransition` @2116-2149), neglect drop (3371), dunmer home favor
  (`NotifyDiegeticRoutineFavor` @5584/5622). So the surfacing machinery exists and is proven --
  the quest-reaction path simply never invokes it.

## The design question to answer first (do NOT assume it's a pure bug)

The Mega Packet Section A says meta lanes should "land as a **Ledger driver** with the humanized
reason ... plus an AwardPiety line." The owner rule "Ledger monitors all data points" (memory
`ledger-monitors-all-data-points`) makes a Ledger/dashboard driver row the minimum wiring bar.
Open questions for the fix session, in order:

1. **Does the Prisma Ledger/dashboard driver row populate for quest reactions today?** The owner
   only checked toast + Book of Days, not the in-panel Ledger. If driver rows ARE landing via the
   PrismaBridge push, the "gap" may be only the toast/BoD beat, which may be intentional silence
   (per-quest toasts would be spammy). Check the recent-events / driver feed path
   (`AppendRecentDevotionEvents` and the PrismaBridge dashboard payload) on a fresh save first.
2. **Is a toast/Book of Days beat even intended for routine quest reactions?** Day-to-day signals
   are deliberately quiet elsewhere; only milestones/transitions chronicle. Decide the intended
   surface per event class: routine cell award vs meta-faucet award vs milestone-value award.
   Driver copy = trigger, not flavor (memory `driver-copy-describe-trigger-not-flavor`) if a
   Ledger row is added.
3. Only after 1-2: wire whatever surface is missing at the decided altitude. Candidate insert
   point is `ApplyQuestReactionPiety` (1890) / the tail of `EvaluateQuestMetaFaucets` (1400), using
   the existing `AppendBookOfDaysEntry` / `Dispatch` helpers. Respect anti-farm (don't toast every
   farmed act) and the once-guard already on meta lanes.

## Secondary finding (minor, same file -- fold in or spin out)

Stale VMAD property-init warnings at game load, manager script no longer contains these:
`PDV_Notif_Redguard_Crown_NeglectTexture`, `..._Forebear_NeglectTexture`,
`..._AshAbah_NeglectTexture`, `..._AncestorLayer_NeglectTexture`. Harmless (properties dropped
from the script, values orphaned on the quest record) but they spam the log at every load. Clean
up the four orphaned properties on the `PDV__ManagerQuest` quest record (CK / houseCARL) when
convenient. Unrelated to the surfacing gap.

## Not a blocker for the smoke run

The reachability gate, piety math, meta lanes, stance flips, and 0.4x path rate all proved out in
Block 1. This handoff is a player-facing surfacing item, tracked separately so Sitting 1 can
continue (Blocks 3-9 + E + C). Re-confirm Block 2 (Dunmer) actually ran under origin 5 first --
the 2026-07-05 log shows only Imperial-stance events, no Dunmer-native Azura+/Mephala/Boethiah/362.

## References

Mega Packet: `references/authoring/PDV_MegaPacket_OneOh_2026-07-02.md` Section A · Sitting 1
runsheet (scratchpad) · memories `ledger-monitors-all-data-points`,
`driver-copy-describe-trigger-not-flavor`, `diegetic-surfacing-d0-gated`,
`prisma-parity-docs-stale-vs-livesource`.

---

## RESOLUTION (2026-07-05, fix session)

### Design questions answered
1. **Does the Ledger/dashboard driver row populate for quest reactions today? YES.**
   `ApplyQuestReactionPiety -> AwardPiety -> AwardPietyInternal` calls
   `RecordDeityDriver(deity, reason, appliedAmount)` (10240) on every non-zero
   award, and that ring is rendered by `AppendDashboardGod -> GetDeityDriversJson`
   (2503/2514). `HumanizeDriverReason` already has bespoke copy for the meta lanes
   (`meta_zen_wage` -> "a quest paid in gold"). The panel piety ring also updates via
   `RequestPanelRefresh()`. So the in-panel dashboard was surfacing quest reactions
   the whole time; the owner had only checked toast + Book of Days. Also: the
   **active patron** already got a toast on a positive quest reaction via
   `AwardPietyInternal` (10247) -- the owner's non-patron test hid even that.
2. **Is a toast/BoD beat intended for routine quest reactions?** Owner ruling:
   quest reactions are milestone-grade and few in practice, so YES -- toast + BoD +
   panel for a landed **base** quest-reaction cell. Meta faucets and behavioral
   faucets stay quiet-Ledger-only (anti-spam / meta once-guard).

### Wired (PDV__ManagerQuest.psc; live-source + MO2 build copy, compiled 0/0, verifier FAIL=0)
v1 (per-cell toasts) proved spammy in the owner's first in-game run -- a Khajiit
assassination stage landed 6 gods (Sithis-/Mephala/Boethiah/Baan Dar/Rajhin/
Clavicus Vile) = 6 beats per stage, several stages per minute. All reactions were
CORRECT per the Khajiit stance table (natives full rate, TOLERATED princes 0.4x,
Sithis TABOO negative, Molag Bal curse-routed, off-roster humans skipped); only
the surfacing altitude was wrong. NOT related to having no active patron.

v2 (shipped): per-quest-fire aggregation.
- Accumulator members (`_qrSurf*`) reset at top of `ApplyQuestReaction`, fed per
  landed base cell via `AccumulateQuestReactionSurface` (gated `!isFaucet &&
  magnitude != "meta"`), flushed after the cell loop by
  `FlushQuestReactionSurface` = ONE toast + ONE Book of Days line per quest fire.
- Toast names the strongest reactor ("Mephala and 3 others mark your deed."); the
  BoD line lists every landed god ("Mephala, Boethiah, ... marked your deed;
  Sithis took offense."). Mixed fires lead tone/symbol with the stronger side
  ("A deed weighed").
- TABOO/HOSTILE deity stigma (real negative piety, e.g. Sithis for Khajiit) now
  folds into the aggregate as displeasure -- v1 missed it entirely (early return).
  Daedric-path stigma stays quiet (stigma is not piety).
- `_suppressAwardFavorToast` still mutes the generic active-patron favor toast
  across quest awards (no double toast).
- New journal tone `favor.loss` (title + warning valence); milestone cells weigh
  BoD magnitude 2.
- Known accepted edges: surfacing uses pre-gain-pipeline amounts; duplicate stage
  events (seen once from a save reload) re-fire the beat -- owner ruled real
  in-game duplicates can't happen, no once-guard added.

### Still open
- **In-game route proof (the gate):** complete a watched quest stage for a roster
  deity on a new save / `coc qasmoke`; confirm toast + BoD line + driver row, and
  single-toast for the active patron; test a negative cell for the ill-received
  path.
- **Orphaned VMAD props (secondary, closed 2026-07-05):** The four
  `PDV_Notif_Redguard_*_NeglectTexture` properties were stripped from the live
  `PDV__ManagerQuest [00C325]` VMAD in `Devotion.esp`. Readback now shows the
  manager property count at `415` with all four orphan names absent; see
  `PDV_Handoff_OrphanRedguardVMAD_Cleanup.md`.
