# PDV Race-Testing Retest Addendum -- 2026-06-27

**Purpose:** fold this session's fixes into future race testing. Everything below is
**built + compiled (0/0) but in-game proof PENDING** -- it needs a fresh Skyrim launch
(the recompiled `.pex` only loads on relaunch) and a NEW save per race (state inits on a
fresh save). Merge these into the per-race V1 run-sheets at their next revision.

## NEW machine preflight (run before any in-game race session)
The reverse-trace gate now catches dead reward ladders / unreachable patrons BEFORE you
burn an in-game session on them:

```
node tools/pdv_deity_chain_audit.mjs        # RESOLUTION + REACHABILITY, must read 0 blockers
node tools/pdv_deity_chain_audit.mjs --self-test   # confirms the gate itself still works
node tools/pdv_integrity_harness.mjs --skip-slow   # deity_chain now rides in the bundle
```
Add this to the gate-bundle step of every run-sheet's preflight.

## Per-race retest cases (new/changed this session)

### Nord
1. **Old Ways now has Mara** (roster = Kyne/Shor/Tsun/Stuhn/Mara/Talos). On an Old Ways
   Nord, feed Mara mercy/hearth acts (heal, cook, clear bounty) to >=50 + 2 signal-days ->
   confirm she fires a commitment offer, and on accept the **"Mara's Mercy/Compassion"**
   rewards apply (Restoration + wake-mended). Confirm she renders in Survey / Ledger /
   Book of Days with her own icon.
2. **Nine Divines reward ladder now lives** (was dead: 7 gods bound to None). Commit to
   each of Akatosh / Arkay / Stendarr / Zenithar / Dibella / Julianos / Kynareth under the
   Nine Divines baseline -> confirm tier rewards actually apply (they reuse the Imperial
   Divine spells). Previously these granted nothing.
3. **Kyne neglect fades on commitment.** Focus a NON-Kyne patron (e.g. Stuhn), lapse a few
   days -> "The Weather Stops Cooperating" must NOT appear (it only fires now if Kyne is
   your own patron). Counter-test: as a Kyne patron, neglect IS expected.

### Orc
4. **Malacath is now active from origin** (was an unreachable dead ladder). A new Orc
   should be Focused-Malacath from character creation; confirm the life-mode reward ladder
   (Stronghold/City/Legion) climbs Seeker -> Devoted -> Champion as Malacath piety rises.
   Before this fix only the always-on spine boon worked.

### Khajiit
5. **Azurah focus icon fix.** Force/earn the Azurah lunar focus -> the focus toast/turn
   line now renders the **'azura'** glyph (was blank/fallback). Cosmetic.

## Cross-cutting (Authoria / Requiem specifically)
6. **Neglect rework (in progress, Codex):** neglect debuffs are being re-authored FLAT
   (Requiem-felt) and to bite on a ~few-day lapse, not just curse -- e.g. Nord Kyne
   `ResistFrost -8`, Imperial `ResistDisease -5`. When that lands, retest that neglect is
   actually FELT under Requiem and bites after a lapse. See
   `PDV_NeglectRework_NordImperial.md` / [[neglect-rework-flat-felt-on-lapse]].
7. **Requiem reward-feel gap (flag, not yet fixed):** the reused Imperial rewards for
   **Akatosh / Julianos / Kynareth** are regen-rate (Magicka/Stamina Regen ~0 under
   Requiem). In Authoria those three Nine Divines tier rewards won't be felt yet -- expected
   until the reward-side Requiem-conversion pass.

## Source of these changes
[[deity-chain-audit-2026-06-27]], [[commitment-fades-other-god-neglect]],
[[deity-daedric-unified-worship-model]] (Mara), and the gate spec
`PDV_DeityChainReverseTraceGate_Spec.md`.
