# ARR 2.5 Non-Quest Adjudication

Date: 2026-08-06  
Target: ARR 2.5 KoK R11  
Proof state: machine-verified experimental; runtime evidence remains open

## Closure boundary

The selected non-quest signature universe is closed at the inventory layer. The
direct record reconciliation retained 125 authoritative records plus 8 roll-up
rows. None of those 125 records was already wired to a current Devotion source.
This closeout promotes only actions with a truthful existing observation seam.
Cosmetic, balance, override, support, and internally consumed records remain
`NO-ROWS`; uncertain content is not converted into coverage.

## Applied now

### Green Pact food classification: 17 records

Four exact-name KID rules cover 14 new animal foods and three Kabu gourd ALCHs.
The animal names are Fox Roast, Bear Haunch, Mammoth Roast, Sabre Cat Steak,
Troll Steak, Roasted Dog Meat, Chub Loon Breast, Grilled Chub Loon Breast,
Cliff Racer Tail, Cliff Racer Stew, Frog Legs, Fried Frog Legs, Raw Bantam Guar
Thigh, and Roast Bantam Guar Haunch. All three Kabu records display as `Gourd`
and receive the plant keyword. Potion name filters are intentional: KID form
filters on ALCH records address effects rather than the item itself.

Authority: `references/authoring/PDV_ARR25_GreenPact_KID.ini`. The Authoria
combined package carries an identical file.

### Breton Hidden Art renewable

An ancestral-dream reflection now also awards Julianos through the real
`SIGNAL_PATRON_CIVIC_FAVOR` property. It keeps the existing shared once-per-day
dream multiplier, raising `breton_hidden_art` from 1/2 to 2/2 without inventing
a quest row. The signal-floor report is now 51/51 PASS.

### Aetherium Forge Destroys Items

AFDI exposes no resolving event or stage. Its destruction script latches 30
artifact globals only after successful consumption, so `PDV_PlayerEvents`
observes those globals every 15 real-time seconds through the existing unified
scheduler. On first install into an existing save, version 1 baselines current
values without retroactive credit. Later 0-to-1 transitions are persisted before
routing and can score only once.

- Ordinary Daedric artifacts: owner displeasure, Stendarr approval, Syrabane
  approval, then one consolidated toast and one Book of Days beat.
- Black Star: Azura approves destruction of the profaned variant; Stendarr and
  Syrabane also approve.
- Auri-El's Bow/Shield and the Sithis artifact: direct roster-gated displeasure.
- Necromancer's Amulet: Arkay and Stendarr approve; Mannimarco is not invented as
  a deity target.
- Jyggalag: observed and logged, but classify-only.

The generic AFDI activator and list were rejected as observers because they do
not identify a successfully completed destruction.

### Daedric shrine prayers

The stale package file that swapped shrine statues to Devotion QASmoke senders
was removed. The combined lane now ships the read-back 11-ACTI compatibility ESP
and its matching Base Object Swapper file. These route prayer (`202`, once/day),
not QASmoke (`200`, commitment). Jyggalag remains absent. Direct readback also
showed the Wyrmstooth placements use different base forms, so they do not inherit
these swaps and are not claimed as covered.

### Bard performances

No new implementation was required. The existing optional Become a Bard and
Skyrim's Got Talent observer already has bounded 5/15-second cadence, a 12-second
double-route guard, one award per tavern per devotional day, and the global daily
repeat multiplier. Runtime proof remains open.

## Deferred after direct review: 108 records

- 49 ALCH: 13 teas, 35 sweets, and 1 brandy. Their names or consumption alone do
  not establish a sufficiently specific devotional act.
- 16 ACTI, 10 BOOK, 8 ARMO, 20 SPEL, and 5 WEAP. These are content, system, or
  acquisition surfaces without a safe resolving observer, or would double-credit
  an already scored outcome.

The exact records and primary verdict notes remain in
`PDV_ARR25_ContentInventory_2026-08-06.csv`; this document does not replace that
row-level authority.

## Hunting boundary

Simple Hunting Overhaul's `_DamagedCarcass` state means already poached/not
carryable, not a completed player action. Immersive Hunting Animations writes
distinct skinned, harvested, butchered, and extracted corpse tokens only after
its animations, but exposes no safe PDV-only observer. A truthful integration
requires the third-party script to emit a ModEvent after each token write and to
retain once-per-corpse-action identity. Polling nearby corpses or repurposing
inventory acquisition would create false credit, so hunting is explicitly
deferred outside this package.

## Machine gate

Run `node tools/pdv_arr25_nonquest_check.mjs`. It verifies source contracts,
exact AFDI globals, isolated PEX/package parity, KID bytes and names, shrine
assets, Hidden Art closure, likes/dislikes version 20, and bard anti-farm guards.

Support remains closed until every OPEN case in
`PDV_ARR25_NonQuest_RuntimeEvidenceLedger.json` has equivalent tester evidence.
