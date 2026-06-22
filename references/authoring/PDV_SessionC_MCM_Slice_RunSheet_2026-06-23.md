# Session C - MCM slice run-sheet (CORRECTED + POST-FIX, 2026-06-23)

Supersedes the **BEFORE-BED SLICE (A1-A6)** section of
`PDV_SessionC_RunSheet_2026-06-22.md`. Same goal: prove the flat/pool health
rewards move the HP bar under Requiem and set the tuned magnitudes.

This version is written for the manager AFTER the 2026-06-23 "Option 1" fixes
(compiled 0/0, verifier FAIL=0, committed). Two of the three false-FAIL traps in
the 06-22 sheet are now fixed in code; the third (Argonian substrate layer) is a
limitation you work around. Verified against live source
(`PDV__ManagerQuest.psc` + `PDV_MCM.psc`) and the per-race reward specs.

## What changed in code on 2026-06-23 (so this sheet is simpler than before)

- **Broad "+10 floor" now grants in broad worship.** Previously the origin's
  first-tier Health floor (`Civic/Tradition/Malacath/Orthodox _T1`) only fired
  for an ACTIVE patron, so a broad worshipper had a 0 -> +20 cliff at 6 acts.
  Now `IsBroadFloorEligible()` grants the floor to a broad worshipper with
  accumulated service (count >= 3, half the Faithful gate of 6). So broad rows
  read the **full stack at Faithful** (see deltas below), not +20-only.
- **"Apply target piety" now self-resyncs the reward family.**
  `DebugForceSetPietyByIndex` now calls `SyncFirstTierRaceRewardRuntime()`, so a
  focused/emphasis reward grants on the seed. **You no longer need the extra
  "Run dawn pass" press** for A2/A6.

## What the MCM page can drive (read this first)

| Row | Driver | Clean Health read at Faithful/Champion |
|-----|--------|----------------------------------------|
| A2 Khajiit Baan Dar (focused) | focus-force + apply piety | +20 / +30 |
| A3 Breton broad Tradition | Seed broad lane button | **+30** (T1 +10 + T2 +20) |
| A5 Imperial broad Civic | Seed broad lane button | **+30** (T1 +10 + T2 +20) |
| A4 Orc broad Malacath | Seed broad lane button | **+20 Health** (+ ~45 armor; Orc T1 floor is armor, not Health) |
| A6 Imperial Arkay (focused) | patron override + apply piety | +30 / +40 net |
| A1 Argonian Hist | only the +30 Signature point is MCM-readable | +30 only |

A7 Mara, A8 Dunmer home, B1 Redguard, B2 HoonDing stay in the LATER/triggered
section (real gameplay) - unchanged from 06-22.

## Trap status vs the 06-22 sheet

1. **A2/A6 "Apply target piety" reading 0 - FIXED in code.** Apply-piety now
   resyncs the reward family; no "Run dawn pass" press needed. (The button still
   works if you press it - it is just no longer required.)
2. **A1 Argonian wrong layer - STILL A LIMITATION.** Hist tier rewards gate on
   the substrate Hist relation (`PDV.Substrate.ArgonianHist.Hist`, 25/50/75),
   NOT `PDV_Deity_Hist` piety. "Apply target piety on Hist" grants nothing
   (false 0). No MCM control seeds the substrate to an intermediate value; the
   only Argonian button ("Argonian focus -> People") forces the relation to 90 =
   **Signature only (+30)**. Treat A1 as a single +30 read; T1/T2 need
   `cqf DebugSeedArgonian` (which we do not use).
3. **A3/A5 broad reading +20-only - FIXED in code.** The +10 floor now grants in
   broad worship, so the seed button (count=6) reads the full **+30** at Faithful.
   (You still cannot ISOLATE the +10 Seeker step alone via the seed button,
   because it always seeds count=6; the +10 floor's standalone value is the spec
   value and it kicks in organically at 3 acts.)

## SETUP (do once)

Identical to the 06-22 sheet steps 0-2: fix the ARR load order (enable the
`Devotion - PlayerDevotion Local Test` junction, disable `PDV_Authoria_FirstLook`;
keep `PDV_AuthoriaARR_Compatibility`); fresh disposable save on the latest build;
`set PDV.UI.DeveloperOptions to 1`; MCM DebugLevel 2; Papyrus log on. Per-heal
read = `player.getav Health` before and after; record (after - before).

> NOTE: this run needs the 2026-06-23 build (the two fixes above). The ESP is
> unchanged, so no Reqtificator re-run; only the recompiled `PDV__ManagerQuest.pex`
> needs to be live. Launch from the Anvil/ARR instance that points at the live
> Devotion build.

## THE MCM SLICE (post-fix drivers + expected deltas)

| # | Race / lane | Driver (exact MCM steps) | Expect (record felt delta) |
|---|---|---|---|
| A2 | **Khajiit Baan Dar (focused)** | `set PDV_GLO_OriginRace to 6`; MCM "Khajiit focus -> Baan Dar"; "Selected deity" -> Baan Dar; "Target piety" 50; "Apply target piety"; getav. Repeat at 85. | **+20** (Devoted) / **+30** (Champion). Seeker(25)=0 Health (DamageResist +15 only). |
| A3 | **Breton broad Tradition** | `set PDV_GLO_OriginRace to 2`; "Seed broad lane (origin)" (Yes); getav. | **+30** at Faithful (T1 +10 + T2 +20 Health; T2 also ResistMagic +5). |
| A5 | **Imperial broad Civic** | `set PDV_GLO_OriginRace to 1`; "Seed broad lane (origin)" (Yes); getav. | **+30** at Faithful (T1 +10 + T2 +20 Health; T2 also ResistDisease +10). |
| A4 | **Orc broad Malacath** | `set PDV_GLO_OriginRace to 8`; "Seed broad lane (origin)" (Yes); getav. | **+20 Health** at Faithful (T2 Health 20; T1 floor is DamageResist +15, T2 DamageResist 30 -> ~+45 armor, no extra Health). |
| A6 | **Imperial Arkay (focused)** | (Imperial) "Selected deity" -> Arkay; **"Debug patron override"** (Set selected deity active); "Target piety" 50; "Apply target piety"; getav. Repeat at 85. | **+30** net (Devoted) / **+40** net (Champion). = Arkay T2/T3 (+20/+30) + Civic T1 origin floor (+10). Bare focused number = net minus 10. Seeker=0 Health. |
| A1 | **Argonian Hist (Signature only)** | `set PDV_GLO_OriginRace to 7`; MCM "Argonian focus -> People"; getav. | **+30** (Hist Signature). T1/T2 not MCM-isolable - record this one point. |

After each focused seed (A2/A6), use **"Show piety map"** to confirm the active
commitment stuck - patron/Prince exclusivity can sever a prior seed.

**Record format:** per row, Health before/after at each tier + a one-word gut
read (thin / right / strong) vs the expected value, under Requiem.

## Magnitudes - verified against the specs (provisional pending YOUR HP read)

Every delta above matches the live reward spec/code (Argonian Hist
T1/T2/Sig 10/20/30; Khajiit Baan Dar T2/T3 20/30; Breton/Imperial broad T1+T2
10+20; Orc broad T2 Health 20; Imperial Arkay T2/T3 20/30; Civic T1 floor 10).
Machine-true but **not yet HP-bar-proven under Requiem** - that read is the point.

Flip note: A1 Argonian Hist T1 and A2 Baan Dar T2/T3 are in the
`PDV_RequiemRegenFlips_Proposal` (proposed to flip from a Health pool to Fortify
HealRateMult >100). If you approve that proposal, those pool deltas become
out-of-combat regen reads instead of `getav Health` deltas.

## Spec drift to fix in the tune-back (not a test blocker)

- **Orc Code Holds (A9)**: `PDV_OrcRewardRecords.spec.json` still documents the
  retired HealRate regen MGEF; the live build pays a flat
  `RestoreActorValue(Health,40/60)` + Stamina 30. Trust the live code; resync the
  spec before any spec-driven re-author.
- **B2 HoonDing Champion AvoidDeath**: restore amount + trigger % live only in the
  ESP MGEF (`PDV_MGEF_Redguard_HoonDing_T3_AvoidDeath`) - needs a houseCARL read
  to bring its magnitude into the tune-back scope.
- **Make-way is a PIETY pulse (3.0), not a heal** - do not log it as an HP delta.

## Deferred to a gameplay session (unchanged from 06-22)

A7 Imperial Mara (sleep), A8 Dunmer home-prayer (urn book at/away-from declared
home), A9 Orc Code Holds (near-death combat), B1a Tu'whacca death-rite, B1b
Namira feed, B2 HoonDing make-way + AvoidDeath. All have verified-matching
magnitudes and can be tier-seeded via MCM, but the heal itself needs the real
trigger. See `PDV_SessionC_RunSheet_2026-06-22.md` LATER section + the per-race
beta-feel run-sheets.
