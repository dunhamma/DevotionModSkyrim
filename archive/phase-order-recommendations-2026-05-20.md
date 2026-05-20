# PDV Phase Order Recommendations - 2026-05-20

**Created:** 2026-05-20
**Status:** ARCHIVE - point-in-time planning recommendation. If adopted, the accepted
changes land in `PDV_Architecture_v3.md` Section 21.5; this file is a frozen record of
the analysis that preceded them.
**Context:** Written after Slice 1 runtime proof closeout (v3.18, 2026-05-19). The
current v3 Pattern Proving build order is the 12-entry table in Section 21.5 (Slices
0-11). This document proposes 7 targeted changes to that order, with rationale and a
revised 14-entry table.

---

## Baseline: Current Slice Order

| Order | Slice | Status |
|---:|---|---|
| 0 | Baseline inventory | DONE |
| 1 | Normal-play ingress closeout | DONE |
| 2 | Imperial Concordat reputation pilot | Pending |
| 3 | Bosmer Path state pilot | Pending |
| 4 | Dunmer Ancestor substrate pilot | Pending |
| 5 | Khajiit lunar exception closeout | Pending |
| 6 | Contextual favor pilot | Pending |
| 7 | Commitment offer pilot | Pending |
| 8 | Daedric price/stigma pilot | Pending |
| 9 | Curse-state pilot | Pending |
| 10 | Neglect/decay pilot | Pending |
| 11 | Privilege pilot | Pending |

---

## Recommended Change 1: Insert a base-script verification slice at position 2

**What:** Add a new thin slice between Slice 1 (done) and the first pilot slice. This slice
compiles `PDV_SubstrateBase`, `PDV_ReputationTrack`, and `PDV_StateTrack` as base
scripts, extends the verifier to cover their source/pex freshness and expected
property/function signatures, and confirms the interface contract before any pilot slice
depends on it.

**Why:** The current plan has each base script first compiled and proved inside its pilot
slice (reputation in Slice 2, state track in Slice 3, substrate in Slice 4). If a base-script
interface contract needs correction - wrong function signature, wrong StorageUtil key
prefix, missing helper - the fix happens inside an already-complex pilot slice that is also
proving race-specific behavior. Separating the base from the pilot means each pilot slice
starts from a known-good base and the verifier has a clean gate before content work begins.

**Cost:** Low. The base scripts already exist architecturally. This slice adds one dedicated
compile-and-verify pass with no new Papyrus content and no CK record work.

**New position in proposed table:** Slice 2.

---

## Recommended Change 2: Move neglect/decay from position 10 to position 9 (before Daedric)

**What:** Swap the order of Slice 10 (neglect/decay) and Slice 8 (Daedric path) so
neglect/decay is proved before Daedric.

**Why:** This is the highest-risk ordering issue in the current table. Every piety threshold
value tuned in Slices 2-7 is calibrated against a monotonically accumulating system.
Neglect/decay introduces a floor and a daily drain (0.5 piety/day default = 3.5/week).
Once it lands, players who held 50 piety easily in commitment testing will find that
holding 50 requires actual behavioral maintenance. All offer thresholds, track band
boundaries, favor amplitude values, and commitment re-qualification windows are
potentially miscalibrated against a no-decay world. Moving decay before Daedric means
the Daedric price/stigma/boon math - the most complex balancing work in the mod - is
done in a decay-aware world. It also means the commitment pilot (now at position 9 in
the revised table) can tune its 7-day re-qualification window with the knowledge of what
daily drain looks like.

**Cost:** Medium. Moving decay earlier means the decay subsystem needs to be fully
built before Daedric, which is additional upfront work. However, the architectural spec
for neglect/decay (Sections 14-15 of v3) is already complete, and the subsystem has
no unresolved open decisions blocking it.

**New position in proposed table:** Slice 10 (after commitment, before privilege).

---

## Recommended Change 3: Move contextual favor from position 6 to position 12 (after neglect/decay)

**What:** Move the contextual favor pilot from Slice 6 (currently before commitment) to
after neglect/decay is established.

**Why:** Contextual favor duration buckets and piety-advantage amounts are calibrated
against whatever baseline piety state the tester has. Without decay, a single session of
normal play can push piety to 80+ and keep it there, making "how much does a 2-4
hour favor actually matter?" hard to judge. After decay is running, the player's piety
oscillates in a realistic band, and the favor system can be tuned knowing what "normal
baseline" looks like.

The current entry gate for favor is "at least one reliable signal family from Slices 1-5,"
which will still be true at the later position. The favor system has no hard dependency
on commitment or Daedric path; it only needs working signals, which exist from Slice 1.

**Cost:** Low reorder cost, meaningful calibration gain. The favor subsystem (Section 10)
has no open decisions blocking it at any position.

**New position in proposed table:** Slice 12.

---

## Recommended Change 4: Add a signal breadth pilot slice at position 8 (before commitment)

**What:** Add a new slice that proves 3+ distinct non-shrine, non-custom signal families
against at least one deity: specifically PO3 Book Read, PO3 Shout Attack, and Story
Manager kill qualifier. These represent the three main signal bus pathways (PO3 events,
Story Manager events, and custom ACTI/MGEF receivers already proved in Slice 1).

**Why:** The commitment offer pilot (current Slice 7) evaluates whether a player has
"qualifying signal activity on at least two separate in-game days within the last seven
days." This evaluation is only meaningful if the signal families that generate that activity
are confirmed to work. Slices 2-5 prove the behavior gates and substrate patterns but
they build on the Slice 1 receivers (custom ACTI/MGEF). The commitment pilot should
enter a world where vanilla-derived PO3 signals have been confirmed to route correctly,
not a world where all tested signals are authored test records.

A single slice that proves one PO3 book read, one PO3 shout use, and one SM kill
classification hitting the EventBus correctly takes very little time and provides meaningful
gate confidence.

**New position in proposed table:** Slice 8.

---

## Recommended Change 5: Move the privilege pilot from position 11 (last) to position 11 in the revised table (before Daedric)

**What:** Privilege remains at roughly position 11 in the revised table, but it now
precedes Daedric rather than following it. The key change is that Daedric moves to 13,
so privilege ends up two slots earlier in terms of what depends on what.

**Why:** Every Champion moment described in `PDV_TargetEndStates_1.0.md` includes
some form of "recognition" - shrine dialogue, NPC reaction, altered text - that is a
privilege. By the time Daedric path content is authored, the privilege pattern should
already be proved. Authoring the Daedric Champion moment's recognition privilege should
build on a stable CK Conditions pattern, not prove one at the same time as the Daedric
pilot's price/stigma machinery.

The privilege pilot itself is structurally simple (CK Conditions on mirror globals and track
globals, no Papyrus glue needed for most cases). It has no reason to be last - its
position in the current table appears to be a default rather than a reasoned ordering
decision.

**New position in proposed table:** Slice 11.

---

## Recommended Change 6: Add a UI toast hardening slice at position 13 (before content expansion)

**What:** Add a slice that promotes the Prisma UI toast payload contract from `prototype`
to `stable`, verifies all 5 current event types (`favor`, `dawn`, `neglect`, `tier`, `rivalry`)
with full field coverage (deity, symbol, context, amount, tierLabel, rival, rivalSymbol),
updates the bridge README maturity label, and pins the payload schema as the
authoritative contract.

**Why:** Toast events are currently prototype-level by explicit declaration in
`native/DevotionPrismaBridge/README.md`. All 10 races' authored content will write
toast notifications. If the payload shape changes after authored race content exists,
every authored string that assumes a field name, a field order, or a fallback
expansion path may need revision. A single hardening slice, placed before content
expansion begins in earnest, freezes the contract while the number of call sites is
still small. After this slice, `PDV_PrismaBridge.SendOverlayJson()` calls can be
written with the confidence that the receiver side will not change shape.

The hardening work is primarily documentation and field-coverage verification (does the
UI actually render all field combinations correctly?), not new engineering.

**New position in proposed table:** Slice 13.

---

## Recommended Change 7: Move Daedric path pilot to position 14 (last before curse-state)

**What:** Shift Daedric from current position 8 to position 14 - after decay, privilege,
favor, and UI contract are all proved.

**Why:** The Daedric path pilot is the most complex balancing and design work in the
mod. Prince commitment, price spells, stigma accumulation, race-specific response, and
exit/residue behavior all interact. Running this pilot with decay known, with favor
calibrated, with privilege pattern established, and with a stable toast payload makes the
Daedric integration exercise one of tuning and edge-case verification rather than
simultaneous proof of five interdependent systems. Every other pilot slice should reach
stability before the Daedric pilot begins.

This aligns with the existing note in Section 21.5: "Do not start Slice 8 from the race
sheets alone." Moving it later reinforces that its entry gate should be high.

**New position in proposed table:** Slice 14.

---

## Proposed New Slice Table (14 entries, 0-13)

| Order | Slice | Change from current table |
|---:|---|---|
| 0 | Baseline inventory | No change - done |
| 1 | Normal-play ingress closeout | No change - done |
| 2 | Base scripts + verifier extension | **NEW** - SubstrateBase, ReputationTrack, StateTrack compile gates before any pilot |
| 3 | Imperial Concordat reputation pilot | Renumbered from 2; entry gate now includes Slice 2 |
| 4 | Bosmer Path state pilot | Renumbered from 3; entry gate now includes Slice 2 |
| 5 | Dunmer Ancestor substrate pilot | Renumbered from 4; entry gate now includes Slice 2 |
| 6 | Khajiit lunar substrate + focused emphasis | Renumbered from 5; entry gate now includes Slice 2 |
| 7 | Neglect/decay pilot | **MOVED** from 10 - proved before commitment and Daedric; all threshold tuning becomes decay-aware |
| 8 | Signal breadth pilot | **NEW** - proves PO3 book read, PO3 shout, and SM kill routing before commitment eligibility relies on them |
| 9 | Commitment offer pilot | Renumbered from 7; now enters a decay-aware world with 3+ signal families confirmed |
| 10 | Privilege pilot | **MOVED** from 11 - proved before Daedric and content expansion; pattern available for all Champion-moment authoring |
| 11 | Contextual favor pilot | **MOVED** from 6 - calibrated against known decay baseline; entry gate includes Slice 7 |
| 12 | UI toast hardening | **NEW** - promotes payload contract to stable before authored race content writes against it |
| 13 | Daedric price/stigma pilot | **MOVED** from 8 - enters after decay, commitment, privilege, and favor are all tuned |
| 14 | Curse-state pilot | Renumbered from 9; Daedric stigma/price now available as a comparison point for curse multiplier tuning |

Note: the entry counts from 0 to 14, giving 15 rows. The earlier conversational reference
to "14 entries" reflects the 14 non-baseline slices (1-14) or an earlier draft that collapsed
two entries. The table above is the recommended order regardless of row count.

---

## Rejected Options

**Splitting Khajiit lunar into two slices (substrate A, focused emphasis B):** The
split would provide cleaner debugging isolation but would add another slice to an already
long table. The substrate and focused emphasis share their StorageUtil key namespace and
dawn logic; splitting them forces partial-state testing that is itself hard to validate.
Keep them as one slice, but write the Slice 6 packet with two explicit in-game proof
gates (substrate metric proof first, focused emphasis lead proof second).

**Moving contextual favor before commitment:** The current table puts favor at Slice 6,
before commitment at Slice 7. This order makes the favor system prove itself without
relying on accepted-patron state being available. It is architecturally valid but wastes the
calibration opportunity that decay provides. Favor should know what "normal piety looks
like" before its amplitude values are locked.

**Adding a dedicated dawn consolidation smoke slice:** Dawn is the single most
load-bearing processing point in the mod. The argument for a dedicated dawn smoke slice
is that every subsequent pilot assumes dawn works correctly. The argument against is that
dawn consolidation is already smoke-tested as part of Slice 0's baseline inventory and
every pilot slice's exit criteria should include "dawn behavior works." Adding a seventh
new slice purely for dawn is redundant if each pilot's "Done when" criteria explicitly
includes a save-and-wait-for-dawn smoke step, which they should.

---

## Adoption Path

If accepted:
1. Update Section 21.5's "Pattern Proving build order" table in `PDV_Architecture_v3.md`
   with the revised 15-row table above.
2. Add Slice 2, Slice 8, and Slice 12 packet templates to Section 21.5 alongside the
   existing Slice 0 and Slice 1 packets.
3. Update the entry gates for Slices 3-14 to reflect the new renumbering.
4. Log the reorder decision in the v3 revision log (Section 25) with a brief rationale note.
5. No changes to Slice 0 or Slice 1 packets - they are closed and correctly documented.
