# PDV 2.0 FAVOR module — runtime smoke runbook (GATE 0.5 runtime tier)

STATUS: LIVING (authored 2026-08-18). Owner-in-loop, MCM-driven. Proves the extracted
`PDV_ContextualFavorRuntime` behaves at runtime as the pre-extraction inline code did —
the runtime half of GATE 0.5 (static half already green: compile 0/0 + byte-parity).

Because the extraction is a strict pure move (bodies byte-identical modulo `Manager.` /
`FavorRuntime.` qualification, independently verified), the runtime tier's real job is to
prove the **wiring is live** — that the host QUST started and both backrefs resolved, so
the module is not silently inert (None backref → every FAVOR call no-ops). If a favor
round-trips (activate → toast → clear → cooldown), parity holds.

## Preconditions (all confirmed on disk 2026-08-18)
- MO2 Anvil, profile 'Devotion Dev'; `Devotion-V3Dev` ENABLED, 1.5 `Devotion` DISABLED.
- `Devotion.esp` wired: host QUST `PDV_ContextualFavorRuntime` (`0x04071791`,
  StartGameEnabled), 16 Spell fills + `Manager`→`00C325`; manager `FavorRuntime`→`071791`.
- Fresh SEQ deployed (`Devotion-V3Dev/Seq/Devotion.seq` lists the host quest).
- All `.pex` recompiled + deployed; verifier FAIL=0.
- **NOT save-safe: a NEW GAME is required** (the host quest starts at game-start via SEQ;
  an old save never started it).

## Key identifiers (front-loaded)
- Dev unlock (console): `set PDV_GLO_DebugLevel to 3`  (>=1 shows dev tabs; 3 also raises
  trace verbosity into the Papyrus log). `set PDV_GLO_DebugLevel to 0` hides them again.
- MCM **Player** tab → **"Favor"** line = liveness indicator (`FavorRuntime.GetPlayerMcmFavorLine()`).
- MCM **Debug: State & Rewards** tab → **"Contextual favor"** section: buttons
  *Cycle favor lane*, *Cycle favor family*, *Trigger selected favor*, *Clear active favor*.
- Lanes: Kyne · Nord Broad Old Ways · Nord Broad Nine Divines · Altmer.
- StorageUtil keys the runtime writes: `PDV.Favor.ActiveLane`, `PDV.Favor.ActiveFamily`,
  `PDV.Favor.ActiveSpell`, `PDV.Favor.ActiveExpiresAt`.
- Favor spell FormIDs (to spot in Active Effects), e.g. Altmer: `xx070FF9` Dawn Steadiness,
  `xx070FFC` Orthodox Cost (xx = Devotion's load index, 0x04 here).
- Papyrus log: `Documents/My Games/Skyrim Special Edition/Logs/Script/Papyrus.0.log`
  (or the MO2 profile's overwrite Logs). A None-backref fault names `FavorRuntime` or the
  module script — the definitive failure tell.

## Recommended test character
A fresh **Altmer** — the Altmer favor lane is eligible from origin alone (no patron/tier
needed, as long as no Altmer curse is active), so it exercises the most-coupled function
`ResolveEligibleFavorLane` with the least setup. (Alternative: a fresh **Nord**, pick a
startup baseline → broad worship → a Nord-broad lane becomes eligible.)

## Procedure

### 0. Setup
1. Start a **new game** (Altmer recommended); get through to free movement + let the
   startup/origin capture fire (the mod's startup message/choice).
2. Open console → `set PDV_GLO_DebugLevel to 3` → close console.
3. Open MCM → Devotion.

### A. Liveness (the core GATE-0.5 proof)
4. **Player** tab → read the **"Favor"** line.
   - PASS: it renders a value — for a fresh Altmer, `Altmer`; otherwise `None active` or
     `Suppressed by vampire curse`. Any non-blank render proves manager→`FavorRuntime` AND
     the module's `Manager` backref both resolved (the line's helper calls
     `Manager.IsNordVampireSuppressed()`).
   - **FAIL**: line blank / MCM throws, or Papyrus log shows a None-object call on
     `FavorRuntime` → the host quest didn't start (SEQ) or the backref is unfilled. Stop and report.

### B. Activate a favor
5. **Debug: State & Rewards** tab → "Contextual favor" section.
6. Tap **Cycle favor lane** until it reads the eligible lane (Altmer).
7. Tap **Cycle favor family** to pick a family (e.g. an Altmer family).
8. Tap **Trigger selected favor**.
   - PASS: a **toast** fires (the "favor" voice, naming the family act); the Player-tab
     "Favor" line now shows the active favor; the favor spell appears under
     Magic → Active Effects. This exercises `TryActivateContextualFavor`,
     `ResolveEligibleFavorLane`, `GetFavorSpell` (the fill), and
     `SendContextualFavorToast` (`Manager.GetActiveDeity()` + `Manager.SendPrismaEventToast`).
   - Note the toast text + active-effect name (the recorded observation).
   - **FAIL**: nothing happens and the log shows None errors → backref/accessor broken.
   - Expected non-failure: if the selected lane is NOT eligible for this character,
     "Trigger" reports a gate block — that's correct behavior, not a fault; cycle to the
     eligible lane.

### C. Clear
9. Tap **Clear active favor**.
   - PASS: the favor spell is removed (gone from Active Effects); the "Favor" line returns
     to the eligible-lane value. Exercises `ClearActiveFavor`.

### D. Cooldown (optional)
10. Re-select the SAME lane+family and **Trigger** again immediately.
    - PASS: "Trigger" reports blocked by family cooldown (exercises `IsFavorFamilyOnCooldown`
      + `GetFavorCooldownDays`). Wait out the cooldown or pick another family to re-activate.

## Verdict
GATE 0.5 runtime tier PASSES when: the "Favor" line renders (A), a favor activates with a
toast + spell + line change (B), and clears cleanly (C), with **no None-backref errors in
the Papyrus log** across the run. Record the toast text + active-effect name as the golden
observation. Then the pilot (RULES + FAVOR, both tiers green) is complete and Phase 1
fan-out is authorized.

## Cleanup
`set PDV_GLO_DebugLevel to 0` to hide the dev tabs. Flip the MO2 mod toggle back
(`Devotion` on / `Devotion-V3Dev` off) when you want the 1.5 line active elsewhere.
