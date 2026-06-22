# PDV Session Handoff — 2026-06-22

Pick-up doc for the next session. Authoritative status lives in `AGENTS.md`
(Decisions Log 2026-06-22 entry) + `PDV_BetaFeelBurndown.md`; this captures
*this session's* work, what's pending in-game proof, and what's next.

## Headline

The framework is build-complete; the gating work is **in-game proof + reward-
magnitude tuning**. This session shipped a real feature (patron/Prince
unification) + several beta-quality fixes, started Session C, and cracked the
Requiem regen mechanism. **Everything committed is machine-proven; almost
nothing is in-game proven yet.** Tuning is **NOT frozen** — the 1F (Experience
Mode) freeze still gates on Sessions B + C + D.

## Shipped this session (committed + pushed, head 14438f1)

- **Patron/Prince unification** (`ab193cb`): mutually-exclusive commitment
  (commit-to-one severs the other) enforced at the `MakeActiveDaedricPact`
  activation seam (breadcrumb → manager tick); gain/lapse/switch all surface
  (toast + Book of Days); migration v3; full Prisma panel/standing/summary
  Prince-wins conversion; bundled curse-cure toast fix. 2 adversarial review
  rounds. Champion offer binding split to its own ESP task.
- **Bug fixes**: Startup MCM row stale prompt (`79382e5`/`6c6bb37`),
  Curse/Neglect MCM blank-from-Anvil-font (`24a0d0e`).
- **MCM broad-lane debug seed** (`14438f1`): `DebugSeedBroadLane()` + "Seed
  broad lane (origin)" button — broad lanes gate on >=6 count accumulators, not
  deity piety.
- **Hist Sap Token CTD fixed**: compiled the missing `PDV_ArgonianHistSapToken.pex`.
- **Docs**: Session-C run-sheet, Requiem regen flips proposal, AGENTS.md entry.

## PENDING in-game proof (do on next relaunch — Anvil list)

Per task #29 + the fix list — all machine-verified, none HP-bar/eyeball proven:
1. **Unification** — drive via MCM **"Add Prince signal"** (NOT Force-tier, which
   bypasses the funnel by design): prove gain journal, lapse, both switch
   directions, Prince-wins Survey + panel, mutual-sever (other side's spells
   actually removed), migration on a pre-v3 both-save.
2. **Startup row** → "SET: GREEN WAY" (already confirmed once).
3. **Curse/Neglect** → "No curse"/"No neglect" (confirmed); **curse-cure toast**
   → "Lycanthropy is lifted" (was "A curse stirs").
4. **Broad-lane seed** → "Seed broad lane (origin)" applies the broad Fortify-Health.
5. **Hist Sap Token** → reading it no longer CTDs.

## Critical path to the 1F freeze (unchanged)

Finish **Session B** (organic faucet + anti-farm) + **Session C** (Requiem HP-bar
magnitudes — load-bearing) + **Session D** (per-race feel) → hand me the
Session-C tuned magnitudes → I write the tune-back + 1B penalty conversion →
re-run gate → confirm **"tuning frozen"** → hand Codex **1F**.

### Session C state (started this session)
- **Run on ARR/Requiem** (`D:\Wabbajack\modlists\ARR`, profile "PDV Test").
  **FIRST: enable the `Devotion - PlayerDevotion Local Test` junction + disable
  `PDV_Authoria_FirstLook`** (it was running yesterday's stale snapshot; ESPs are
  byte-identical so no Reqtificator re-run). Run-sheet:
  `PDV_SessionC_RunSheet_2026-06-22.md`.
- **A6 Imperial Arkay = on-spec** (+20/+30 focused + broad layer stacking =
  +30/+40 total; pool boost confirmed, the correct Requiem-proof behavior).
- Remaining clean rows: A5 Imperial civic, A3 Breton broad, A4 Orc broad
  (use the new "Seed broad lane" button), A2 Khajiit BaanDar (focus-force first).
- **A1 Argonian deferred** — substrate-gated, no MCM seed (only organic Hist
  maintenance climbs it); the triggered rows (A7-B2) need real gameplay.
- Record the felt Health delta + a one-word gut read (thin/right/strong) per row.

## Open decisions (need a user ruling)

1. **Requiem regen flips** (`PDV_RequiemRegenFlips_Proposal_2026-06-22.md`):
   approve the 6 pool→regen flips + the **>100 HealRateMult ceiling exception**
   (the legacy 15/30 ceiling is Requiem-swallowed — drain is 100). Then it
   becomes a reward-author build spec.
2. **Hist Sap Token base type**: book (current design) vs potion (your memory —
   likely a live-only edit the 06-20 restore reverted). I won't flip it without
   your call.

## Tracked follow-ups (not blocking)

- **Champion Accept/Decline offer binding** (task #30): orphaned `..._ChampionEntry`
  MESG never bound to the 16 path-quest VMADs → offer never displays. Own
  ESP/houseCARL + save-migration task.
- **V2 backlash** (turning from a Prince) — `PDV_V2_Backlog.md §4`.
- **Curated-signal slider 999 cap** (task #16) + **panel keyboard-close** (#17).
- **Toolchain gap**: `pdv_compile`/`pdv_verify` don't track
  `PDV_ArgonianHistSapToken` (it silently never built; gate stayed green).
- **Nord broad accumulator** not yet wired in `DebugSeedBroadLane`.

## Gotchas / environment

- **Mixed-case MCM labels = the Anvil Font Overhaul typeface**, not Devotion
  (deployed `.pex` is provably Title-Case). And that font **blanks an MCM value
  of exactly "None"** — never return a bare "None" for a display value.
- **Live manager is untracked**; the tracked mirror is `live-source/Scripts/Source/`.
  After any live edit, sync the mirror + commit (done this session).
- houseCARL: re-point to **Anvil (Devotion Dev)** after any ARR read.
- Requiem regen mechanism: drain = 100 on HealRateMult (constant); a Fortify must
  EXCEED 100 to be felt; food ~115, mid-potion 220.
