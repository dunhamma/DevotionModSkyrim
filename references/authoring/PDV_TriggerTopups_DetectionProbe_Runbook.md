# Trigger Top-Up — Detection Probe Runbook

Status: **Pre-implementation.** Proves the five detection primitives behind
`PDV_TriggerTopups_Exchange_KnightsRoad.md` actually fire on a vanilla save *before* any
scoring is wired. Each probe is a trace-only hook (`Debug.Trace`, no piety effect). If a probe
does not produce its expected line, that hook is not buildable as designed — redesign before
spending wiring effort.

This runbook proves **detectability only**. It does not prove scoring, anti-farm caps, theology,
or immersion — those land with the normal scoring pass once the primitives are confirmed.

## Preconditions

```powershell
node .\tools\pdv_verify.mjs --json
```

Use a clean save with a Bosmer or Breton (race is irrelevant to detection — the probes are
race-agnostic trace hooks). Archive the Papyrus log first so no probe passes on a stale trace:

```powershell
if (Test-Path "$env:USERPROFILE\Documents\My Games\Skyrim Special Edition\Logs\Script\Papyrus.0.log") { Rename-Item -Path "$env:USERPROFILE\Documents\My Games\Skyrim Special Edition\Logs\Script\Papyrus.0.log" -NewName ("Papyrus.0.detprobe-" + (Get-Date -Format "yyyyMMdd-HHmmss") + ".log") }
```

Enable Papyrus logging (`bEnableLogging=1`, `bEnableTrace=1` in `Skyrim.ini` `[Papyrus]`) if not
already on. All probe traces use the prefix `PDV_PROBE:` for a single grep at the end:

```powershell
Select-String -Path "$env:USERPROFILE\Documents\My Games\Skyrim Special Edition\Logs\Script\Papyrus.0.log" -Pattern "PDV_PROBE:"
```

## Probe harness (one temporary quest)

Attach a temporary `PDV_DetectionProbe` quest (Start Game Enabled, trace-only). It registers the
hooks below in `OnInit` / on a player alias. Remove it after the pass — it ships nothing.

---

### Probe 1 — Barter / Training gold-delta (hook Z1: Exchange)

**Hook under test:** `RegisterForMenu("BarterMenu")` / `RegisterForMenu("Training Menu")`, capture
`Game.GetPlayer().GetGoldAmount()` on `OnMenuOpen`, compare on `OnMenuClose`, trace the delta.

**In-game steps:**
1. Open any merchant's barter menu. Note carry gold.
2. **Sell** one item, close the menu. → expect `PDV_PROBE: barter delta=+N (sold)`.
3. Re-open, **buy** one item, close. → expect `PDV_PROBE: barter delta=-N (bought)`.
4. Open and close the menu **without trading**. → expect **no** `barter delta` line (zero-delta suppressed).
5. Pay a trainer for one skill level. → expect `PDV_PROBE: training paid=-N`.

**Pass:** lines 2, 3, 5 present with correct sign; line 4 absent.
**Fail / redesign if:** menu-close fires no event (SKSE menu reg unavailable), or zero-delta opens
spam a line (means Z1 would need a different anti-empty gate).

### Probe 2 — Sneak-attack flag at kill (hook K1: no-stealth-opener gate)

**Hook under test:** Kill-Actor Story Manager receiver (or PO3 `OnDeath`); at the kill read whether
the killing blow / engagement was a sneak attack (`isSneakAttack`, or `Game.GetPlayer().IsSneaking()`
as the v1 proxy) and trace it.

**In-game steps:**
1. Stand openly, kill a lone enemy in melee or at range (not sneaking). → expect `PDV_PROBE: kill sneak=FALSE`.
2. From stealth (Sneak eye hidden), land a sneak-attack kill. → expect `PDV_PROBE: kill sneak=TRUE`.
3. Open with a sneak shot that wounds but does not kill, then kill in open combat. → record what
   `sneak` reads on the *killing* blow (this tells us whether the gate keys on opener vs killing blow).

**Pass:** step 1 = FALSE, step 2 = TRUE.
**Decide from step 3:** if the killing-blow flag reads FALSE after a stealth *opener*, the K1 gate
must track "engagement opened from stealth," not just the killing blow — note which, it changes the
hook spec.
**Fail / redesign if:** the flag is unreadable at the kill event (then K1 can't distinguish ambush
from honest combat and "honorable arms" is not buildable as specced).

### Probe 3 — Predatory faction membership at kill (hook K1: predator gate)

**Hook under test:** at Kill-Actor, check victim `IsInFaction(BanditFaction)` /
`IsInFaction(ForswornFaction)`; trace which matched.

**In-game steps:**
1. Kill a generic bandit (road/cave bandit). → expect `PDV_PROBE: victim predator=Bandit`.
2. Kill a **bandit boss / chief** (unique-faction enemy). → expect `predator=Bandit` (proves boss
   sub-factions still inherit `BanditFaction`) — **or note its absence**.
3. Kill a Forsworn. → expect `predator=Forsworn`.
4. Kill a **non-predator** (a guard, a hostile wolf, a Draugr). → expect `PDV_PROBE: victim predator=NONE`.

**Pass:** steps 1, 3 match; step 4 = NONE.
**Decide from step 2:** if a bandit boss reads NONE, the predator set needs the unique boss factions
added (enumerate them) — a known Skyrim wrinkle where chiefs sit in a unique faction.
**Fail / redesign if:** vanilla `BanditFaction`/`ForswornFaction` EditorIDs don't resolve (unlikely;
they are vanilla) — then substitute the correct form IDs.

### Probe 4 — Crime-gold / fine paid (hook Z1: settle-a-debt half)

**Hook under test:** Story Manager crime node (`OnStoryCrimeGold` / arrest path) or a poll of
`Game.GetPlayer().GetCrimeGold()` dropping to zero after the pay-fine dialogue; trace it.

**In-game steps:**
1. Commit a minor crime to earn a bounty (e.g. pickpocket-fail or trespass) in a hold.
2. Surrender to a guard and **pay the fine**. → expect `PDV_PROBE: fine paid=-N hold=<Hold>`.
3. (Alt) Pay a bounty at a Jarl's steward if that path differs. → expect the same trace.

**Pass:** a `fine paid` line on the pay path.
**Fail / redesign if:** neither the crime node nor a crime-gold poll catches the payment — then the
"settle a debt" half of Z1 drops to fines-via-dialogue-only (curated), and Z1 leans more on barter.

### Probe 5 — Beggar charity dialogue (hook K2: charity topper)

**Hook under test:** curated `Adjust`/trace fragment on the vanilla beggar "here's some gold"
dialogue topic(s); confirm the topic fires a fragment we can hook.

**In-game steps:**
1. Find a beggar (e.g. Riften, Windhelm, Whiterun).
2. Use the give-gold charity dialogue. → expect `PDV_PROBE: charity beggar=<NPC>`.
3. Note the **topic/quest form ID** the fragment lives on (needed for the real K2 `Adjust`).

**Pass:** a `charity beggar` line + recorded topic ID.
**Fail / redesign if:** the vanilla beggar charity is a hard-coded package with no script-attachable
fragment — then K2 charity needs a small custom dialogue view or drops in favor of a different aid hook.

---

## Results ledger

Record per probe so the spec can be finalized:

| Probe | Result | Notes / IDs captured | Spec impact |
|-------|--------|----------------------|-------------|
| 1 Barter/training delta | PASS / FAIL | | |
| 2 Sneak flag at kill | PASS / FAIL | opener-vs-killing-blow = ? | |
| 3 Predator faction | PASS / FAIL | boss sub-faction IDs = ? | |
| 4 Fine paid | PASS / FAIL | node vs poll = ? | |
| 5 Beggar charity | PASS / FAIL | topic ID = ? | |

## Exit

- **All 5 PASS** → `PDV_TriggerTopups_Exchange_KnightsRoad.md` is buildable as written; proceed to
  the scoring/anti-farm wiring pass.
- **Any FAIL** → apply that probe's "redesign if" note to the spec before wiring. None of the five
  failing modes is fatal to the *path* — each has a documented fallback — but they change which hook
  carries the floor, so resolve them first.
- Delete the `PDV_DetectionProbe` quest; it is trace-only and ships nothing.
