# PDV Signal Floor - Likes/Dislikes v15 - Codex Handoff - 2026-07-09

## What shipped (already done, do not re-author)

- `references/authoring/PDV_DeityLikesDislikes.csv`: 340 -> 363 rows (23 new).
- Codegen (`node tools/pdv_likesdislikes_gen.mjs`) folded into the live
  `LoadRowsForDeity` body in BOTH copies of `PDV__ManagerQuest.psc`
  (repo `live-source\Scripts\Source\` and MO2
  `D:\Wabbajack\modlists\Anvil\mods\Devotion\Scripts\Source\` - synced
  live-source -> MO2 before compile per the split-toolchain rule).
- `GetLikesDislikesEventTypes()` (the ClearRowsForDeity superset) extended from
  32 to 34 entries: added event IDs **303** and **366** (first-ever consumers).
- `LIKES_DISLIKES_VERSION` 14 -> 15 (forces clear + reload on next game load).
- Version pins synced 14 -> 15 in `tools/pdv_verify.mjs`
  (`EXPECTED_LIKES_DISLIKES_VERSION`) and
  `tools/pdv_deity_signal_remap_adversary_check.mjs` (mechanical contract sync
  - review welcome).
- Compile: `node tools/pdv_compile.mjs --script PDV__ManagerQuest` - 0 errors /
  0 warnings. Gates: strict dislike-consequence audit PASS, adversary PASS
  (363 likesRows), verify 3546 PASS / 0 FAIL / 1 pre-existing WARN.

## The 23 new rows (summary)

Theme: the previously-unconsumed dispatch events **366 EVT_VAMPIRE_FEED** and
**303 EVT_KILL_ANIMAL_NONCOMBAT** carry most of the new negative pressure.

- 366 feed-as-vampire NEGATIVE (capped): Arkay -1.5 large, Stendarr -1.5 large,
  Tu'whacca -1.5 large, Mara -1.0, Kynareth -1.0, auri-el -1.0, azurah -1.0,
  kyne -0.75, Talos -0.75, Dibella -0.75, khenarthi -0.75, HoonDing -0.75,
  magnus -0.5, rajhin -0.5.
- 366 feed-as-vampire POSITIVE: sithis +0.5, Mephala +0.35 (secret predation).
- 303 kill-animal-noncombat NEGATIVE: kyne -0.5, Kynareth -0.5.
- kyne 365 raise-undead -1.0 (conditionTag ActorTypeUndead, existing tag).
- Leki 360 pick-owned-lock -0.25 (conditionTag owned; face-the-owner ethic).
- Baan Dar 351 clear-bounty-serve-time -0.25 (pariah pays no debt to the law).
- Stuhn 313 rest-under-open-sky +0.25; alkosh 344 increase-skill +0.25.

All rows use dispatchable event IDs only; every repeatable is capped
(dailyCap/cooldownDays); tier/delta values follow existing conventions
(small +/-0.25-0.5 cap 3; medium +/-0.75-1.0 cap 2 / cd 0.5; large +/-1.5
cap 1 / cd 1.0). No pickpocket rows (type-3 unrouted). HoonDing/Leki
generic-combat exemption honored (their new rows are discipline-framed
dislikes, not combat likes).

## Dispatch-surface facts verified this pass

- 303 is genuinely dispatched: `PDV_ActionRouter.ClassifyNonHostileKillVictim`
  returns EVT_KILL_ANIMAL_NONCOMBAT for ActorTypeAnimal non-hostile kills, and
  the manager already carried 303 rows in the Prince PLD table.
- 366 dispatch was previously proven (curated-signal gate); it had zero V1 LD
  consumers until this pass.

## Proof boundary

Proven: CSV authority, codegen fold, superset extension, version bump, compile
0/0, static gates. NOT proven: any in-game piety movement from the new rows.
LD table reload requires the version bump to run: **prove on a NEW save or a
save that has not yet stamped PDV.LD.Version=15.**

## In-game smoke (MCM-driven; no cqf)

1. New save, any race; confirm log line "Likes/dislikes table + stances loaded
   (version 15)".
2. Vampire feed (contract vampirism or debug): expect Arkay/Stendarr-class
   LOSSES in the Ledger (Ledger monitors losses; panel filter ORs recent
   movement), correct driver copy stating WHEN it fired, daily cap enforced on
   a second feed same day (large tier: cap 1).
3. Kill a non-hostile animal (e.g. a chicken/deer out of combat): kyne and
   Kynareth -0.5, cap 3/day.
4. Leki active-context: pick an OWNED lock; expect -0.25 with `owned`
   condition; an unowned lock must stay silent for Leki.
5. Save/load: no duplicate rows, no stale movement re-fires.
6. Anvil MCM font caveat: any new MCM-visible strings must never render bare
   "None" (existing rule; no MCM text changed this pass).

## Follow-up work for Codex

1. **Syrabane LD lane (deferred)**: Syrabane has ZERO LD rows and is not an LD
   actor. Adding him needs: rows in the CSV, `ClearRowsForDeity`-reachable
   fan-out (he must be in the deity iteration set), codegen regen, version
   bump. Design intent: ward-casting / protective-magic repeatables, capped.
2. **Driver copy**: verify the humanized reasons for eventName
   `feed-as-vampire`, `kill-animal-noncombat`, `pick-owned-lock`,
   `clear-bounty-serve-time` state the trigger (driver rows say WHEN they
   fire, never poetic flavor). If a shared-ID relabel needs new copy, route via
   the existing `[disp]` HumanizeCuratedSignalReason path.
3. **Stendarr positive floor**: he is negative-heavy by design (conscience
   deity); if his positive lane ever needs help it should come from quest rows
   (Dawnguard hunter-side candidates were left unrowed for Stendarr this pass
   because he was already at floor).

## Rebuild loop (if rows change again)

```powershell
# edit references/authoring/PDV_DeityLikesDislikes.csv
node tools/pdv_likesdislikes_gen.mjs      # paste function body into PDV__ManagerQuest.psc (live-source)
# update GetLikesDislikesEventTypes() if a NEW event ID appears; bump LIKES_DISLIKES_VERSION
# sync live-source -> MO2 copy, then:
node tools/pdv_compile.mjs --script PDV__ManagerQuest
node tools/pdv_dislike_consequence_audit.mjs --strict-dislike-consequence --json
node tools/pdv_deity_signal_remap_adversary_check.mjs
node tools/pdv_verify.mjs --json
# keep the two version pins (pdv_verify.mjs, adversary check) in lockstep
```
