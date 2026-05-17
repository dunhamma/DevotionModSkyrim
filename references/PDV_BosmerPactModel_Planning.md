# Bosmer Pact Model — Planning Patch

> **Status:** Ratified 2026-05-17. The summaries in `race-sheets/Race_Bosmer.md`
> (Old Contract section, Path Switching section, Hircine entry) and
> `references/PDV_RaceArchitecture_DesignReference.md` (sections 4.2 and 10.7)
> reference this doc as the authoritative spec. This file remains the source
> of truth for state model, bands, transitions, and the lifetime cycle cap.
> Wild Hunt is removed from the Bosmer player-facing model. Other Bosmer paths
> (Living Story, Exchange, Bandit Road) are unchanged by this patch.

---

## Two course corrections

1. **Wild Hunt drops as a player-facing track.** It remains lore context for
   why the Pact exists, but is never a gameplay state, meter, or proximity
   signal. No `WildHuntProximity` track ships.
2. **Y'ffre is a path commitment, not a soft-scaled deity.** Following the
   Green Pact is a binary state. While bound, other deity boons are locked
   out (existing ledgers preserved but frozen). Leaving returns the player
   to the default Bosmer pantheon.

## State model

### `PactBound` — binary path flag

- Storage: `PDV.State.PactBound` (int 0/1).
- Mirror global: `PDV_GLO_PactBound` for CK Condition reads.
- Set true via setup choice or in-world commitment ritual.
- Set false via voluntary renunciation or forced reckoning (see Transitions).

**While `PactBound == true`:**

- Y'ffre is the only deity that accepts new devotion gains or fires blessings.
- All other Bosmer-recognized deity ledgers freeze at current values.
  Devotion is preserved but inert.
- `GreenPactCompliance` is active and tracked.
- Y'ffre gains/losses scale by GPC band (see below).

**While `PactBound == false` (default Bosmer state):**

- Full Bosmer pantheon access via standard PDV piety mechanics.
- `GreenPactCompliance` is inactive (frozen at last value for record only).
- Y'ffre ledger persists at whatever level it reached during the prior bound
  period, but Y'ffre is now one option among many — no exclusivity, no GPC
  scaling.

### `GreenPactCompliance` — discipline meter (only meaningful while bound)

- Float, 0-100. No passive decay.
- Driven by acts: losses from plant interaction (alchemy on flora, woodcutting,
  flora harvest); gains from hunting and protection acts.
- Hybrid detection: FormLists are authoritative; keyword fallback is a
  strict-mode opt-in only.
- Bands and Y'ffre devotion multipliers:

  | Band      | GPC range | Y'ffre gain multiplier | Notes |
  |-----------|-----------|------------------------|-------|
  | Apostate  | 0-19      | 0% (locked out)        | Triggers forced reckoning after sustained dwell |
  | Lapsed    | 20-49     | 50%                    | Functional but visibly degraded |
  | Observant | 50-79     | 100%                   | Default healthy state |
  | Strict    | 80-100    | 120%                   | Reward for sustained discipline |

  Losses are symmetric (Argonian precedent): Strict band absorbs minor
  violations more gracefully; Apostate band cannot recover gains without
  re-entering Lapsed first.

### `LapsedFromPact` — lifetime cycle counter

- Storage: `PDV.State.LapsedFromPact` (int, default 0).
- Increments on each completed renunciation (voluntary or forced).
- Caps re-entry at one cycle (see Lifetime cap).

## Transitions

### Setup choice (MCM first-load)

Three options surfaced for Bosmer characters:

- **Sworn to the Green Pact** — `PactBound = true`, `GPC = 80`,
  `LapsedFromPact = 0`. Y'ffre as exclusive patron.
- **Free of the Pact** — `PactBound = false`, no GPC, `LapsedFromPact = 0`.
  Default pantheon access.
- **Lapsed Adherent** — `PactBound = false`, no GPC, `LapsedFromPact = 1`.
  Narrative flag for "former adherent." Tooltip must state that taking the
  Pact later and renouncing again will trigger the terminal lock.

### Entering the Pact mid-game

- MCM toggle `Take the Green Pact`.
- Gated by a one-time qualifying act in the current session (recorded
  animal kill within the last N in-game days). Prevents frictionless
  switching.
- On commit:
  - `PactBound → true`.
  - `GPC` initializes at 60 (Observant low) on first entry, or at 20
    (Lapsed floor) on re-entry after a prior renunciation.
  - All non-Y'ffre Bosmer-recognized ledgers freeze at current values.
  - Y'ffre ledger resumes from its frozen value if re-entering.

### Leaving the Pact — voluntary

- MCM toggle `Renounce the Pact`. Single confirmation prompt.
- Immediate. Clean exit.

### Leaving the Pact — forced reckoning

- Trigger: `GPC` remains in Apostate band (0-19) for 3 consecutive in-game days.
- One-shot notification fires:
  *"You have lived against the Pact. Re-commit, or be cast from Y'ffre's song."*
- Player choice:
  - **Re-commit:** `GPC` snaps to 30 (Lapsed). `PactBound` stays true.
    `LapsedFromPact` does not increment.
  - **Renounce:** standard exit path (below). `LapsedFromPact` increments.
- No silent auto-renounce. The decision is always surfaced.

### Exit effects (both voluntary and forced renunciation)

- `PactBound → false`.
- `GPC` stops tracking; frozen at last value for record-keeping only.
- Y'ffre ledger frozen at current devotion. Not zeroed.
- All other Bosmer-recognized deity ledgers unfreeze and resume normal
  mechanics.
- `LapsedFromPact` increments by 1.

### Re-entry

- Permitted exactly once — when `LapsedFromPact == 1`.
- Same MCM toggle and qualifying-act gate as initial mid-game entry.
- `GPC` initializes at 20 (Lapsed floor), not 60. Trust is rebuildable but
  not free.
- Y'ffre ledger resumes from frozen value; gains scale by new GPC band.
- Other-deity ledgers re-freeze.

## Lifetime cap — second renunciation is terminal

- When the transition logic detects `LapsedFromPact == 1` at the point of
  another renunciation (voluntary or forced), the exit is **terminal**:
  - `PactBound → false`.
  - Y'ffre ledger frozen **permanently** at current devotion. Visible in
    status screen as a read-only historical value. No further gains or
    blessings fire.
  - `LapsedFromPact → 2`.
  - MCM `Take the Green Pact` toggle disables. Tooltip:
    *"Y'ffre's song no longer answers you."*
- Other Bosmer-recognized deities remain fully available. The cap closes
  the Pact, not the pantheon.

### Terminal-warning text

Both the forced-reckoning prompt and the voluntary renunciation MCM toggle
must detect `LapsedFromPact == 1` and rewrite their confirmation text to
make finality explicit:

> *"This will end your bond with Y'ffre. You will not be able to return."*

Single confirmation, no double-prompt. The warning lives in the text, not
in extra friction.

## What this supersedes

- **`race-sheets/Race_Bosmer.md` — The Old Contract section:** the "compliance
  mechanics" framing remains correct in spirit, but specifics (band thresholds,
  forced reckoning, lifetime cap, re-entry rules) now derive from this doc.
  Ratification into the race sheet is a separate step.
- **Any pending Wild Hunt player-track design:** removed. Wild Hunt is lore
  context only.
- **Path-switching language in `Race_Bosmer.md`:** "hardest to leave and hardest
  to re-enter" stands, but the *mechanism* is now the cycle cap above rather
  than open-ended difficulty.

## Open items deferred to implementation

- Exact FormList contents for Pact-violating and Pact-honoring acts (Phase 4
  signal matrix update).
- Whether Spinner NPCs or in-world Y'ffre shrines get added via patch to host
  the entry/exit ritual; until then, MCM is the only surface.
- Whether the forced-reckoning grace period (3 in-game days) needs MCM tuning
  exposure or stays a constant.
- Status-screen presentation of frozen Y'ffre ledger after terminal lock.
