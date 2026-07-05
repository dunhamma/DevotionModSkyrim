# PDV Session Handoff -- 2026-07-05 Mega Packet Sitting 1 (Anvil) closeout + verifier reconcile

## TL;DR

Mega Packet Sitting 1 (Anvil) is functionally COMPLETE: Section A (8 origins), the E1 day-to-day
signal sweep, and all Block-F mechanics passed in-game. The sweep caught **4 real end-to-end
wiring bugs** -- ALL 4 now fixed + proven in-game. One loose end for Codex: a
`pdv_verify` FAIL that is verifier contract-drift from the `360` fix (not a functional
regression). Strict beta gate still `STRICT_GATE_PASS`.

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

## Still pending for Sitting 1 / next Anvil boot

- **C1/C2 Prisma render checks** (universal sheet U1-U9 + the 2026-07-01 beat spot-checks) -- NOT
  run this sitting; still owed for the Sitting-1 scope.
- **Surfacing live re-verify** (the ONLY in-game unknown left): the surfacing fix now emits an
  AGGREGATED one-per-quest-fire toast + Book of Days line (not per-cell) -- unseen on screen yet
  because it was compiled after the Section A run. Fire a base quest-reaction cell on the next
  Anvil boot to confirm. (341 is already PROVEN via its own fix -- do NOT re-confirm.)

## Gate state at handoff

`STRICT_GATE_PASS` (PASS=31, WARN=1, INFO=2, blockers=[]). `pdv_verify` PASS=3511, WARN=2,
**FAIL=1 (the PickLock-node verifier drift above -- the only thing to clear)**. After that clears,
resume the 1.0 roadmap: Experience Mode build -> ARR compat -> WS-3 branding.
