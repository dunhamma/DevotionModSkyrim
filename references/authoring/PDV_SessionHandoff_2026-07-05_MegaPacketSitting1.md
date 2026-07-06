# PDV Session Handoff -- 2026-07-05 Mega Packet Sitting 1 (Anvil) closeout + verifier reconcile

## TL;DR

Mega Packet Sitting 1 (Anvil) has now closed Block 1 plus the Universal Prisma sheet:
Section A (8 origins), the E1 day-to-day signal sweep, all Block-F mechanics, and
Prisma U1-U9 passed in game. The sweep caught **4 real end-to-end wiring bugs** in
the Section A/E1 pass, then the Prisma pass caught a second wave of player-facing
surface bugs; the closed Prisma fixes listed below were re-verified in game. The only
remaining Sitting-1 Prisma work is C2 beats 3, 5, and 6. Strict beta gate still
`STRICT_GATE_PASS` from the prior gate run; this handoff does not claim a fresh repo
gate after the 2026-07-06 Prisma run.

## IMMEDIATE for Codex -- reconcile the pdv_verify FAIL (contract drift)

`node .\tools\pdv_verify.mjs --json` now reports **FAIL=1** (was 0):

```
[FAIL] Generic faucet Story Manager node: PDV__SM_PickLockNode:
  parent is Devotion.esp:071618, expected Skyrim.esm:05BD7B
```

Cause: the `360` fix (commit 61cb48d8 / merge 4b4b8e7c) confirmed the vanilla SM LockPick route
(`05BD7B:Skyrim.esm`) is dead and re-parented `PDV__SM_PickLockNode` onto a new PDV event node
`071618:Devotion.esp`, with a **menu-hook fallback** as the mechanism that actually fires `360`
in game (proven: `EventBus: Zenithar event 360 delta -0.5`). The ESP is correct and `360` works;
`pdv_verify` just still hardcodes the OLD expected parent (`05BD7B`).

Action: update the `pdv_verify.mjs` "Generic faucet Story Manager node" check for
`PDV__SM_PickLockNode` to expect parent `071618:Devotion.esp` (or reconcile the check with the
menu-hook architecture -- decide whether the re-parented SM node is intentional-but-inert next to
the menu-hook, and whether the check should still assert it at all). Toolchain edit (`pdv_verify.mjs`)
-- owner-authorized on 2026-07-05. Re-run to FAIL=0 after.

## Sitting 1 results (intake into existing trackers / runbook -- do NOT create a parallel handoff)

**Section A -- quest expansion (all 8 setstage-able origins passed):**
- Reachability gate proven BOTH directions: native pantheons score full; off-roster FOREIGN/
  TOLERATED gods skip-trace (`QuestReaction skipped unreachable foreign deity`) with no piety /
  no Ledger row. Confirmed per-origin: Imperial(1), Nord(3-mercy), Bosmer(4 meta_zen_wage),
  Khajiit(6 Rajhin via DB06/DB09 re-run), Altmer(5-wheel), Redguard(9 Tu'whacca), Orc(8 Malacath+
  state), Dunmer(5 Azura+Mephala/Boethiah).
- Akatosh/Xarxes 10th-quest wheel fired: Xarxes full + Akatosh skip under Altmer (A5). Counter is
  per-DISTINCT-quest and resets on save-reload (StorageUtil) -- documented for future runs.
- **362 steal route PROVEN in-game both sentiment sides**: Dunmer like-side (Mephala +0.5/Boethiah
  +0.25) and Imperial dislike-side (Zenithar -1.0 + Divines). Retires the last 362 pending flag.
- Dunmer(2) A3/E3 done; the earlier "Block 2 not in log" was a same-session origin/steal gap, since
  closed.

**E1 day-to-day sweep (Imperial primary) -- CSV-exact, remaining rows now covered:**
craft 330/331/332/333, knowledge 340/342/343/344, sleep 313/314, combat-murder 304, steal 362,
artifact 368 -- all deltas match `PDV_DeityLikesDislikes.csv`. Mechanics: attribution filter,
anti-farm daily cap (`repeatable event ... blocked by daily cap`), dawn-bank (ProcessDawn banks
PietyToday->Piety), and the race-gate all confirmed. NOTE the race-gate criterion: 330/314 are
richly two-sided so no origin yields literal "scored 0"; the real proof is the ORIGINAL native
deity dropping out on flip (Imperial Zenithar/Dibella/Mara gone under Argonian; only Sithis/Hist
score) -- update any run-sheet that still expects a bare "scored deities 0".

**Talos finding (packet E1 expectation is STALE):** Talos never scores the generic day-to-day
likes/dislikes under Imperial origin (343/344/etc.) -- he is **stance-1 tolerated** (Concordat),
excluded from the hard race-gated generic table, but curated Imperial signals still feed him at
0.4x (seen: civic-sleep -> `Talos raw 1.0 applied 0.5 stance 1`, signal 104; banked at dawn
0.5->0.66). Recommend editing Mega Packet Section E1 to drop the "Talos +1.0 on 343 / +0.25 on
344 / -0.75 on 304" expectations for Imperial.

## Bugs found this sitting (4)

1. **341 read-spell-tome never fired** -- OnBookRead does not fire for consumed-on-learn tomes;
   classifier + 93-item FormList were correct but never reached. FIXED + recorded.
2. **360 pick-owned-lock never fired** -- vanilla SM LockPick route dead; fixed via re-parent +
   menu-hook fallback. FIXED + confirmed live (Zenithar -0.5). *(Leaves the verifier drift above.)*
3. **365 raise-undead never fired** -- effect-apply hook never saw reanimation (target-side / the
   RegisterQuestReactionFaucetEvents UnregisterForAll clobber); fixed via caster-side OnSpellCast
   (commit 0a1f90f1). FIXED + confirmed.
4. **361 trespass + 364 assault never fired** -- aiCrime gate. FIXED + PROVEN 2026-07-05 (merged
   bcb4d6f7): 361 is a detection gate (Zenithar -0.25 x3 in game); 364 was a TIME-conjunction bug
   (`aiCrime > 0 AND not-hostile` were never both true at once) -- fixed to skip only when
   `aiCrime == 0 && hostile`. Note: assault's aiCrime is a LARGE packed non-zero value (logged
   903454209), not a 0/1 flag. See [[aicrime-gate-trespass-assault-dead]].

Pattern: all 4 are the recurring PDV failure class -- "declared + scripted but the event never
reaches the handler end-to-end." Machine gates passed on all of them; only in-game exercise caught
them.

## Prisma checkpoint -- 2026-07-06

**Universal sheet U1-U9: PASS in game.** Confirmed surfaces:

- U1 cold-open focus plus ESC/X/Book-key close.
- U2 Seeker/Devoted/Champion tier-up toasts and Book of Days entries; standing label is
  patron-owned by design, so an uncommitted patron can read "Unproven" while the gauge itself
  reflects piety.
- U3 active-patron favor toast and dawn digest.
- U4 Ledger driver rows, substrate visibility, curated driver copy, pre-pact "Watching" badge,
  and named watching-onset Book of Days line.
- U5 ordinary Book of Days pruning with milestones pinned.
- U6/U7 neglect lapse and recovery; confirmed by design that active patron piety is decay-shielded
  and neglect is a recency-lapse debuff after three days without devotional action.
- U8 formal offer accept/refuse copy and pinned Book of Days entries.
- U9 whole-record read: toast, Chronicle, and Ledger read as one surface, not disconnected systems.

**Same-day Prisma fixes re-verified in game:**

- Orkey Old Ways offer + "Orkey" normalize-gate naming; internal key remains Arkay.
- Curated driver copy now names the real trigger, such as "defiant prayer at a Talos shrine",
  instead of generic "a devotional rite".
- Pre-pact watching Prince badge and named watching-onset Book of Days line.
- Surfacing aggregation: one toast plus one Book of Days line per quest fire, not one burst per
  matrix cell.

**Filed / still open from the Prisma pass:**

- `task_387bfc95`: MCM Debug curated-signal slider caps at 0-999, while many deity signal IDs are
  1000+.
- `task_e6904bb3`: Orkey/Dibella patrons have no neglect debuff spell.
- `task_7dab1ebb`: Hircine renunciation over-fires and replaces the intended renounce copy; residue
  should arrive later rather than same-frame.

`task_8c27e440` was implemented after this checkpoint: formal offer Refuse now calls
`SurfaceTransition(..., silent=True)` and removes the warning toast, so only the pinned refusal
chronicle writes. Accept remains fully surfaced. Machine gates passed; manual smoke is still owed.

`task_e6904bb3` was also implemented after this checkpoint: Orkey/Dibella Old Ways neglect records
and manager wiring are machine/readback closed. Orkey uses the internal Arkay key but displays
"Orkey's Neglect" with `ResistMagic -5`; Dibella displays "Dibella's Neglect" with `Restoration -5`.
Manual smoke is still owed for both Active Effects rows.

**Testing gotchas captured:** the MCM "Selected deity" is a debug cursor, not the active patron, and
resets on page reset; cycle it to the target before every Force Piety / Apply action. Commitment
offers need piety >= `COMMITMENT_OFFER_THRESHOLD` (50) plus seeded signal-days. `set timescale`
only advances game time while the console is closed.

## Still pending for Sitting 1 / next Anvil boot

- **C2 beat 3 -- Altmer alignment band:** drive Thalmor alignment across a committed band; confirm
  the band toast and chronicle.
- **C2 beat 5 -- Khajiit Champion pin:** force a Khajiit patron to Champion, run dawn, then wait
  22+ days; confirm the Champion chronicle survives pruning.
- **C2 beat 6 -- Redguard sect Champion toast:** drive a Redguard sect to Champion entry; confirm
  the per-sect Champion toast.

Do **not** rerun Universal Prisma U1-U9 just to close Sitting 1; it passed on 2026-07-06 unless a
new Prisma/source change invalidates the evidence.

## Gate state at handoff

Prior gate state before the Prisma checkpoint: `STRICT_GATE_PASS` (PASS=31, WARN=1, INFO=2,
blockers=[]). `pdv_verify` subsequently had a PickLock-node verifier drift in this handoff, and a
later reconcile cleared that class in the living burndown. After C2 beats 3/5/6 close, resume the
1.0 roadmap queue from the current burndown rather than this dated gate count.
