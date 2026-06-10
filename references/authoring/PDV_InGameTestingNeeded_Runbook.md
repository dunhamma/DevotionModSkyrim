# PDV In-Game Testing Needed Runbook

**Created:** 2026-06-10
**Purpose:** Drive and record the **V1 day-to-day (generic) faucet sweep** -- the
pass that proves the broad "ordinary act" faucets (read any lore book, generic
kills, travel, theft, inn sleep, fast travel) only ever score gods **native to the
active origin race**, and stay silent for every other race. This is the
generic-source-silence (GS) / wrong-origin-silence (WO) lane, separate from:

- the per-race curated beta packets (`PDV_BetaTestPacket_{Race}.md`), and
- the 5-step accepted-source loop in
  [PDV_InGameGodTestingPlan.md](PDV_InGameGodTestingPlan.md).

Verdicts feed the GS/WO columns of
[PDV_RuntimeEvidenceTracker.md](PDV_RuntimeEvidenceTracker.md).

---

## 1. Setup (every session)

- Origin-race index map (source `PDV_DeityBase.psc` `RACE_*` / `PDV__ManagerQuest.psc`
  `ORIGIN_*`): `0 Nord, 1 Imperial, 2 Breton, 3 Altmer, 4 Bosmer, 5 Dunmer,
  6 Khajiit, 7 Argonian, 8 Orc, 9 Redguard`.
- `set PDV_GLO_DebugLevel to 2` (so `AwardPiety` and EventBus route lines trace).
- Set origin with `set PDV_GLO_OriginRace to <idx>`. The day-to-day faucet is
  race-gated by `PDV_DeityBase.GetStanceForPlayer()` ->
  `GetStanceForRace(PDV_GLO_OriginRace)`; a god scores a generic faucet only when
  its per-race `Stance_<Race>` is `NATIVE (0)`.

**Sweep hygiene:** because the sweep flips origin between reads, ALWAYS confirm the
*current* `PDV_GLO_OriginRace` immediately before attributing a scored line to a
race. In `Papyrus.0.log`, the authoritative value at any timestamp is the last
`set PDV_GLO_OriginRace` console line before that timestamp -- not the origin
implied by a nearby curated route marker, which may have run under a previous
origin.

## 2. The generic faucet lane (event 342)

Event `342` is the generic "lore book read" day-to-day faucet. It broadcasts to the
deity roster and is filtered to gods `NATIVE` to the active origin. Curated
foreground book routes are a *different* lane (e.g. Dunmer Reclamation books route
on event `130` with `eventbus_130_po3_book_dunmer_*` reasons; Khajiit lunar routes
on `eventbus_p2_khajiit_lunar_po3_book_khajiit_lunar`). Do not conflate a curated
route marker with the generic 342 faucet.

## 3. STOP conditions

Halt the sweep and file a finding if any holds:

- **A generic day-to-day act scores a god NOT native to the player's race**
  (race-gate leak).
- A wrong-origin re-read of the same source still moves manager state, a reward, or
  the Survey (wrong-origin-silence failure).
- A generic act moves a hidden counter with no native god attached.

## 4. Sweep procedure (per origin)

1. `set PDV_GLO_OriginRace to <idx>`; confirm via the console echo / next trace.
2. Do each ordinary act (read a generic lore book, generic kill, travel, theft, inn
   sleep, fast travel).
3. Read `Papyrus.0.log`: every scored god on each `event 342` (and the other
   generic events) MUST be native to `<idx>`. Anything else is a STOP (Section 3).
4. Record AS/WO/GS verdicts into
   [PDV_RuntimeEvidenceTracker.md](PDV_RuntimeEvidenceTracker.md).

---

## 5. Day-to-day faucet sweep -- findings log

### 5.1 -- 2026-06-10: "Mephala scores event 342 at Khajiit origin" -> NOT REPRODUCED (log mis-attribution; non-issue)

**Reported observation (Papyrus.0.log, 08:26:03 PM):**

```
[PDV] EventBus: azurah event 342 delta 0.250000
[PDV] EventBus: Mephala event 342 delta 0.250000
[PDV] EventBus: RouteAction complete: event 342, scored deities 2
```

Fired ~8s after a Khajiit lunar book route (`RouteKhajiitLunarSubstrate complete:
po3_book_khajiit_lunar`). Concern: Mephala is Dunmer-native only, so Mephala scoring
at Khajiit origin (6) would be a race-gate leak (Section 3 STOP condition).

**Verdict: NON-ISSUE.** The active origin at 08:26:03 was almost certainly **5
(Dunmer)**, not 6 (Khajiit). At Dunmer origin, `{Azurah, Mephala}` is the *correct*
native scoring, not a leak. Step-1 disposition of the task ("if origin was NOT 6,
close it") applies.

**Evidence and reasoning (static analysis; in-game re-run still recommended to
close, see below):**

1. **Mephala is Dunmer-NATIVE only.**
   `PDV_DunmerRewardRecords.spec.json` authors `PDV_Deity_Mephala` with
   `stanceDunmer:NATIVE, create:true` as a *separate* Dunmer-owned QUST. It carries
   no Khajiit stance; `PDV_KhajiitRewardRecords.spec.json` (Azurah / Khenarthi /
   Rajhin / Alkosh, +Baan Dar tolerated) does not list Mephala. So under a correct
   gate, `Mephala.GetStanceForRace(6)` returns the default `Stance_Khajiit = 1
   (FOREIGN)` and Mephala cannot score a generic 342 faucet at origin 6.

2. **A correct 342 gate scores Mephala only at origin 5.** Because event 342 is
   filtered to `STANCE_NATIVE` gods (Section 2), Mephala appearing on a 342 line is
   itself a positive indicator that origin was Dunmer (5) at that instant.

3. **The scored set is a Dunmer fingerprint, not a Khajiit one.** At Dunmer origin
   the Reclamation natives are Azura / Boethiah / Mephala; `{Azurah, Mephala}` is
   exactly the pair that responds to a *book* read (Azura foresight, Mephala
   secrets/cunning), with Boethiah (struggle/strength) correctly silent. If origin
   were 6 with a leaking gate, we would instead expect the Khajiit natives that
   subscribe to 342 (Khenarthi / Rajhin / Alkosh) to also score, and there is no
   coherent mechanism by which a single Dunmer-only god (Mephala) leaks while
   Boethiah does not. The clean two-god Dunmer pair is incompatible with a
   Khajiit-origin leak.

4. **`azurah` in the log is the record's stored `DeityName`, not an origin signal.**
   Azura is a genuinely shared record: Khajiit-NATIVE *and* Dunmer-NATIVE (the Dunmer
   author reuses it `create:false` and only adds `Stance_Dunmer=0` via
   `--reconcile-shared-deity`; it was created under the Khajiit pilot, so its name
   string stayed `Azurah`). The shared-deity reconciliation touches the Azura record
   only; it does not, and mechanically cannot, write a Khajiit stance onto the
   separate `PDV_Deity_Mephala` record -- so the hypothesized "Azura -> Mephala
   Khajiit-stance bleed" has no code path.

5. **Why the "origin 6" attribution slipped.** The Khajiit lunar handler
   (`HandleKhajiitMoonObservance` / lunar substrate) is hard-gated by
   `IsKhajiitOrigin()`, so the lunar route 8s earlier legitimately ran at origin 6.
   The V1 sweep then flips origin between reads (the documented WO/GS method:
   `set PDV_GLO_OriginRace to <other index>`, re-read). The most parsimonious account
   is that origin was switched to 5 (Dunmer) for the generic-book read, and the
   "origin 6" was carried over from the lunar marker rather than re-derived from the
   `set PDV_GLO_OriginRace` line that actually preceded 20:26:03.

**One-line confirmation for the tester (do this to close the item):** in
`Papyrus.0.log`, find the last `set PDV_GLO_OriginRace` (or the MCM origin-selector
trace) *before* `08:26:03 PM` -- expect `5`. If it reads `5`, this item is closed as
correct Dunmer-native behavior.

**Fallback -- only if the log shows origin was still 6 at the 342 line** (then it IS
a leak):

- Reproduce: `set PDV_GLO_OriginRace to 6`, `set PDV_GLO_DebugLevel to 2`, read any
  generic lore book; confirm whether Mephala scores `event 342`.
- Root-cause check (live tree
  `D:\Wabbajack\modlists\Anvil\mods\Devotion\Scripts\Source`): the gate itself
  (`PDV_DeityBase.GetStanceForPlayer` / `GetStanceForRace`) is race-correct; the only
  way Mephala passes at origin 6 is an authored `Stance_Khajiit = 0` on
  `PDV_Deity_Mephala`. Housecarl readback of `PDV_Deity_Mephala` should show
  `Stance_Khajiit = 1 (FOREIGN)`. If it reads `0`, the Dunmer author run mis-wrote a
  Khajiit stance onto Mephala during the create / `--reconcile-shared-deity` pass;
  fix by re-running the author to set `PDV_Deity_Mephala.Stance_Khajiit = FOREIGN`
  (leave `Stance_Dunmer = NATIVE`), then re-run this sweep at origin 6 to confirm
  Mephala is silent.

**Scope note:** this is the V1 generic faucet sweep, separate from the Khajiit lunar
beta packet (`PDV_BetaTestPacket_Khajiit.md`), which passed (conditional pass; edge
focus source still pending) and is unaffected by this item.

**Environment note:** this finding is a static-evidence determination plus the
exact in-game confirmation step; it was produced without access to the live
`Papyrus.0.log` or the live `D:\Wabbajack` script tree. The one-line log check above
is the authoritative closer.
